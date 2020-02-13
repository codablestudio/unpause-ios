//
//  Coordinator+Settings.swift
//  Unpause
//
//  Created by Krešimir Baković on 07/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func presentChangePersonalInfoViewController(from viewController: UIViewController) {
        let updatePersonalInfoViewModel = UpdatePersonalInfoViewModel()
        let updatePersonalInfoViewController = UpdatePersonalInfoViewController(updatePersonalInfoViewModel: updatePersonalInfoViewModel)
        viewController.present(updatePersonalInfoViewController, animated: true)
    }
    
    func presentChangePasswordViewController(from viewController: UIViewController) {
        let updatePasswordViewModel = UpdatePasswordViewModel()
        let updatePasswordViewController = UpdatePasswordViewController(updatePasswordViewModel: updatePasswordViewModel)
        viewController.present(updatePasswordViewController, animated: true)
    }
}
