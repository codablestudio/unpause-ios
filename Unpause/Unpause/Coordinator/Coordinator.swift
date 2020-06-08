//
//  Cordinator.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Coordinator {
    
    var window: UIWindow!
    
    static let shared = Coordinator()
    
    private init() {}
    
    func start(_ window: UIWindow) {
        self.window = window
        if SessionManager.shared.userLoggedIn() {
            navigateToHomeViewController()
        } else {
            startAuth()
        }
    }
    
    func logOut() {
        startAuth()
    }
    
    private func startAuth() {
        let loginNetworking = LoginNetworking()
        let companyNetworking = CompanyNetworking()
        let registerNetworking = RegisterNetworking()
        let locationNetworking = LocationNetworking()
        let loginViewModel = LoginViewModel(loginNetworking: loginNetworking,
                                            companyNetworking: companyNetworking,
                                            registerNetworking: registerNetworking,
                                            locationNetworking: locationNetworking)
        let loginViewController = LoginViewController(loginViewModel: loginViewModel)
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window.rootViewController = navigationController
    }
}
