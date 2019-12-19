//
//  Cordinator.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

class Coordinator {
    
    func presentRegistrationViewController(from: UIViewController) {
        let registerViewModel = RegisterViewModel()
        let registerViewController = RegisterViewController(registerViewModel: registerViewModel)
        from.present(registerViewController, animated: true, completion: nil)
    }
    
    func navigateToHomeViewController(from: UIViewController, email: String) {
        let homeViewController = HomeViewController(homeViewModel: HomeViewModel(signedInUserEmail: email))
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        
        let activityViewController = ActivityViewController(activityViewModel: ActivityViewModel())
        let activityNavigationController = UINavigationController(rootViewController: activityViewController)
        
        let settingsViewController = SettingsViewController(settingsViewModel: SettingsViewModel())
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        
        let tabBarViewController = UITabBarController()
        tabBarViewController.setViewControllers([homeNavigationController,
                                                 activityNavigationController,
                                                 settingsNavigationController],
                                                 animated: true)
        tabBarViewController.selectedViewController = homeNavigationController
        
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home_25x25_unselected"), selectedImage: UIImage(named: "home_25x25_selected"))
        activityNavigationController.tabBarItem = UITabBarItem(title: "Activity", image: UIImage(named: "activity_25x25_unselected"), selectedImage: UIImage(named: "activity_25x25_selected"))
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings_25x25_unselected"), selectedImage: UIImage(named: "settings_25x25_selected"))
        
        from.navigationController?.pushViewController(tabBarViewController, animated: true)
        print("\(email)")
    }
}
