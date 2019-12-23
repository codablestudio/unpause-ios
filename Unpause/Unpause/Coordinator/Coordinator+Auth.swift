//
//  Coordinator+Auth.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

// AUTH

extension Coordinator {
    
    func showLoginScreen() {
        
    }
    
    func presentRegistrationViewController(from: UIViewController) {
        let registerViewModel = RegisterViewModel()
        let registerViewController = RegisterViewController(registerViewModel: registerViewModel)
        from.present(registerViewController, animated: true, completion: nil)
    }
}
