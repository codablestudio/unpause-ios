//
//  NotificationManager.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager {
    
    static var shared = NotificationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        notificationCenter.delegate = self as? UNUserNotificationCenterDelegate
    }
    
    func scheduleNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Job alert 📍"
        content.body = "Your location has changed."
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        let region = LocationManager.shared.makeSpecificCircularRegion(latitude: 45.787730,
                                                                       longitude: 15.949608,
                                                                       radius: 50.0)
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            DispatchQueue.main.async {
                guard let error = error else {
                    return
                }
                print("\(error)")
            }
        }
    }
}
