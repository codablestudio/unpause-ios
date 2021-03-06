//
//  CustomTabBarController.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBarController()
    }
    
    private func setUpTabBarController() {
        let homeNetworking = HomeNetworking()
        let shiftNetworking = ShiftNetworking()
        let homeViewModel = HomeViewModel(homeNetworking: homeNetworking, shiftNetworking: shiftNetworking)
        let homeViewController = HomeViewController(homeViewModel: homeViewModel)
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        
        let companyNetworking = CompanyNetworking()
        let activityViewModel = ActivityViewModel(shiftNetworking: shiftNetworking, companyNetworking: companyNetworking)
        let activityViewController = ActivityViewController(activityViewModel: activityViewModel)
        let activityNavigationController = UINavigationController(rootViewController: activityViewController)
        
        let settingsViewController = SettingsViewController(settingsViewModel: SettingsViewModel())
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        
        self.setViewControllers([homeNavigationController,
                                 activityNavigationController,
                                 settingsNavigationController],
                                animated: true)
        self.selectedViewController = homeNavigationController
        
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home",
                                                           image: UIImage(named: "home_25x25_unselected"),
                                                           selectedImage: UIImage(named: "home_25x25_selected"))
        
        activityNavigationController.tabBarItem = UITabBarItem(title: "Activity",
                                                               image: UIImage(named: "activity_25x25_unselected"),
                                                               selectedImage: UIImage(named: "activity_25x25_selected"))
        
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings",
                                                               image: UIImage(named: "settings_25x25_unselected"),
                                                               selectedImage: UIImage(named: "settings_25x25_selected"))
        
        UITabBar.appearance().tintColor = UIColor.unpauseOrange
        UITabBar.appearance().backgroundColor = UIColor.unpauseWhite
    }
}
