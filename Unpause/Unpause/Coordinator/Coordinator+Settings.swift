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
        let updatePersonalInfoNetworking = UpdatePersonalInfoNetworking()
        let updatePersonalInfoViewModel = UpdatePersonalInfoViewModel(updatePersonalInfoNetworking: updatePersonalInfoNetworking)
        let updatePersonalInfoViewController = UpdatePersonalInfoViewController(updatePersonalInfoViewModel: updatePersonalInfoViewModel)
        let navigationController = UINavigationController(rootViewController: updatePersonalInfoViewController)
        viewController.present(navigationController, animated: true)
    }
    
    func presentChangePasswordViewController(from viewController: UIViewController) {
        let changePasswordNetworking = ChangePasswordNetworking()
        let changePasswordViewModel = ChangePasswordViewModel(changePasswordNetworking: changePasswordNetworking)
        let changePasswordViewController = ChangePasswordViewController(changePasswordViewModel: changePasswordViewModel)
        let navigationController = UINavigationController(rootViewController: changePasswordViewController)
        viewController.present(navigationController, animated: true)
    }
    
    func presentAddCompanyViewController(from viewController: UIViewController) {
        let companyNetworking = CompanyNetworking()
        let addCompanyViewModel = AddCompanyViewModel(companyNetworking: companyNetworking,
                                                      registeredUserEmail: SessionManager.shared.currentUser?.email)
        let addCompanyViewController = AddCompanyViewController(addCompanyViewModel: addCompanyViewModel,
                                                                navigationFromRegisterViewController: false)
        let navigationController = UINavigationController(rootViewController: addCompanyViewController)
        viewController.present(navigationController, animated: true)
    }
}
