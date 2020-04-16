//
//  AppDelegate.swift
//  Unpause
//
//  Created by Krešimir Baković on 11/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreLocation
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        guard #available(iOS 13, *) else {
            let newWindow = UIWindow(frame: UIScreen.main.bounds)
            Coordinator.shared.start(newWindow)
            self.window = newWindow
            self.window?.makeKeyAndVisible()
            LocationManager.shared.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            LocationManager.shared.locationManager.pausesLocationUpdatesAutomatically = false
            LocationManager.shared.locationManager.requestAlwaysAuthorization()
            NotificationManager.shared.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if let error = error {
                    print("Error occured: \(error)")
                } else {
                    print("NotificationCenter Authorization Granted!")
                }
            }
            LocationManager.shared.locationManager.startUpdatingLocation()
            NotificationManager.shared.scheduleNotification()
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            return true
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
