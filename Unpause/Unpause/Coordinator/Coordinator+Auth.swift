//
//  Coordinator+Auth.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func presentRegistrationViewController(from viewController: UIViewController) {
        let registerNetworking = RegisterNetworking()
        let registerViewModel = RegisterViewModel(registerNetworking: registerNetworking)
        let registerViewController = RegisterViewController(registerViewModel: registerViewModel)
        let navigationController = UINavigationController(rootViewController: registerViewController)
        viewController.present(navigationController, animated: true)
    }
    
    func presentForgotPasswordViewController(from viewController: UIViewController) {
        let loginNetworking = LoginNetworking()
        let forgotPasswordViewModel = ForgotPasswordViewModel(loginNetworking: loginNetworking)
        let forgotPasswordViewController = ForgotPasswordViewController(forgotPasswordViewModel: forgotPasswordViewModel)
        let navigationController = UINavigationController(rootViewController: forgotPasswordViewController)
        viewController.present(navigationController, animated: true)
    }
}
