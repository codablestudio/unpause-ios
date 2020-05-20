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
import SwiftyStoreKit
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let newWindow = UIWindow(frame: UIScreen.main.bounds)
        self.window = newWindow
        self.window?.makeKeyAndVisible()
        
        setupApplication()
        
        Coordinator.shared.start(newWindow)
        return true
    }
    
    private func setupApplication() {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        LocationManager.shared.configure()
        setupLogger()
    }
    
    private func setupLogger() {
        let console = ConsoleDestination()
        log.addDestination(console)
    }
}
