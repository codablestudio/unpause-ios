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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        let newWindow = UIWindow(frame: UIScreen.main.bounds)
        Coordinator.shared.start(newWindow)
        self.window = newWindow
        self.window?.makeKeyAndVisible()
        LocationManager.shared.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        LocationManager.shared.locationManager.pausesLocationUpdatesAutomatically = false
        LocationManager.shared.locationManager.requestAlwaysAuthorization()
        NotificationManager.shared.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (_,_) in }
        LocationManager.shared.locationManager.startUpdatingLocation()
        return true
    }
}
