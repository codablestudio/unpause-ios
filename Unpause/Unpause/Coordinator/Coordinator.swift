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
    
    var window: UIWindow!
    
    static let shared = Coordinator()
    
    private init() {}
    
    func start(_ window: UIWindow) {
        self.window = window
        
        if SessionManager.shared.userLoggedIn() {
            showTabbar()
        } else {
            showLoginScreen()
//            let loginViewController = LoginViewController(loginViewModel: LoginViewModel())
//            let navigationController = UINavigationController(rootViewController: loginViewController)
//            newWindow.rootViewController = navigationController
        }
    }
}
