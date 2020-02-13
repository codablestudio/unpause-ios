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
        let registerViewModel = RegisterViewModel()
        let registerViewController = RegisterViewController(registerViewModel: registerViewModel)
        viewController.present(registerViewController, animated: true, completion: nil)
    }
}
