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
    }
    
    func scheduleNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
        let entranceRequest = makeLocationBasedNotificationRequest(notificationBody: "You entered job area.",
                                                                   latitude: 45.787730,
                                                                   longitude: 15.949608,
                                                                   notifyOnEntry: true,
                                                                   notifyOnExit: false)
        let exitRequest = makeLocationBasedNotificationRequest(notificationBody: "You left job area.",
                                                               latitude: 45.787730,
                                                               longitude: 15.949608,
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
}
