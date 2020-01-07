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
    func presentUpdatePasswordViewController(from: UIViewController) {
        let updatePasswordViewModel = UpdatePasswordViewModel()
        let updatePasswordViewController = UpdatePasswordViewController(updatePasswordViewModel: updatePasswordViewModel)
        from.present(updatePasswordViewController, animated: true)
    }
    
    func presentUpdatePersonalInfoViewController(from: UIViewController) {
        let updatePersonalInfoViewModel = UpdatePersonalInfoViewModel()
        let updatePersonalInfoViewController = UpdatePersonalInfoViewController(updatePersonalInfoViewModel: updatePersonalInfoViewModel)
        from.present(updatePersonalInfoViewController, animated: true)
    }
}
