//
//  NotificationManager.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class NotificationManager {
    
    static var shared = NotificationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        notificationCenter.delegate = self as? UNUserNotificationCenterDelegate
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
        content.title = "Job alert 📍"
        content.body = notificationBody
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        let region = LocationManager.shared.makeSpecificCircularRegion(latitude: latitude,
                                                                       longitude: longitude,
                                                                       radius: 50.0,
                                                                       notifyOnEntry: notifyOnEntry,
                                                                       notifyOnExit: notifyOnExit)
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        return request
    }
    
    func registerCategories() {
        let show = UNNotificationAction(identifier: "show", title: "Check in/Check out", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        
        notificationCenter.setNotificationCategories([category])
    }
}
