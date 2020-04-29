//
//  NotificationManager.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import UserNotifications
import CoreLocation

class NotificationManager: NSObject {
    
    static var shared = NotificationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    let userChecksIn = PublishSubject<Void>()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        registerCategories()
    }
    
    func scheduleNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
        guard let allUsersCompanyLocations = SessionManager.shared.currentUser?.company?.locations else { return }
        for location in allUsersCompanyLocations {
            let latitude = location.latitude
            let longitude = location.longitude
            
            let entranceRequest = makeLocationBasedNotificationRequest(notificationBody: "You entered job area.",
                                                                       latitude: latitude,
                                                                       longitude: longitude,
                                                                       notifyOnEntry: true,
                                                                       notifyOnExit: false)
            
            let exitRequest = makeLocationBasedNotificationRequest(notificationBody: "You left job area.",
                                                                   latitude: latitude,
                                                                   longitude: longitude,
                                                                   notifyOnEntry: false,
                                                                   notifyOnExit: true)
            notificationCenter.add(entranceRequest) { (error) in
                DispatchQueue.main.async {
                    guard let error = error else {
                        return
                    }
                    print("\(error)")
                }
            }
            notificationCenter.add(exitRequest, withCompletionHandler: nil)
        }
    }
    
    func makeLocationBasedNotificationRequest(notificationBody: String,
                                              latitude: CLLocationDegrees,
                                              longitude: CLLocationDegrees,
                                              notifyOnEntry: Bool,
                                              notifyOnExit: Bool) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        var requestIdentifier = "requestID"
        content.title = "Job alert 📍"
        content.body = notificationBody
        if notifyOnEntry {
            content.categoryIdentifier = "entrance"
        } else if notifyOnExit {
            content.categoryIdentifier = "exit"
        }
        
        content.sound = UNNotificationSound.default
        
        let region = LocationManager.shared.makeSpecificCircularRegion(latitude: latitude,
                                                                       longitude: longitude,
                                                                       radius: 100.0,
                                                                       notifyOnEntry: notifyOnEntry,
                                                                       notifyOnExit: notifyOnExit)
        if notifyOnEntry {
            requestIdentifier = "notifyOnEntry"
        } else if notifyOnExit {
            requestIdentifier = "notifyOnExit"
        }
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        return request
    }
    
    func registerCategories() {
        let entranceAction = UNNotificationAction(identifier: "entranceAction", title: "Check in", options: .destructive)
        let category = UNNotificationCategory(identifier: "entrance", actions: [entranceAction], intentIdentifiers: [])
        
        notificationCenter.setNotificationCategories([category])
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        
        if identifier == "entranceAction" {
            SessionManager.shared.currentUser?.lastCheckInDateAndTime = Date()
            userChecksIn.onNext(())
        }
        completionHandler()
    }
}
