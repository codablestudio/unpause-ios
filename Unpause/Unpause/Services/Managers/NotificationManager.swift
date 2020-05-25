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
}

// MARK: - Location based notifications
extension NotificationManager {
    func scheduleEntranceNotification() {
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
            
            notificationCenter.add(entranceRequest, withCompletionHandler: nil)
        }
    }
    
    func scheduleExitNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
        guard let allUsersCompanyLocations = SessionManager.shared.currentUser?.company?.locations else { return }
        for location in allUsersCompanyLocations {
            let latitude = location.latitude
            let longitude = location.longitude
            
            let exitRequest = makeLocationBasedNotificationRequest(notificationBody: "You left job area.",
                                                                   latitude: latitude,
                                                                   longitude: longitude,
                                                                   notifyOnEntry: false,
                                                                   notifyOnExit: true)
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
        let entranceCategory = UNNotificationCategory(identifier: "entrance", actions: [entranceAction], intentIdentifiers: [])
        let exitCategory = UNNotificationCategory(identifier: "exit", actions: [], intentIdentifiers: [])
        
        notificationCenter.setNotificationCategories([entranceCategory, exitCategory])
    }
}

// MARK: - Time based notifications
extension NotificationManager {
    func scheduleTwelveHourDelayNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Check out reminder"
        content.body = "It looks like you are still working, would you like to check out?"
        let notificationRequestID = "twelveHourNotificationRequestID"
        guard let dateComponents = Formatter.shared.getTimeTwelveHoursFromCurrentTime() else {
            return
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationRequestID, content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: nil)
    }
}

// MARK: - UNUserNotificationCenter delegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier

        if identifier == "entranceAction" && SessionManager.shared.currentUser?.lastCheckInDateAndTime == nil {
            SessionManager.shared.currentUser?.lastCheckInDateAndTime = Date()
            userChecksIn.onNext(())
            completionHandler()
        }
    }
}
