//
//  Coordinator+Tabbar.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func navigateToHomeViewController() {
        NotificationManager.shared.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (_,_) in }
        
        let customTabBarController = CustomTabBarController()
        window.rootViewController = customTabBarController
    }
}
