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
    func presentAddCompanyViewController(from viewController: UIViewController) {
        let companyNetworking = CompanyNetworking()
        let addCompanyViewModel = AddCompanyViewModel(companyNetworking: companyNetworking,
                                                      registeredUserEmail: SessionManager.shared.currentUser?.email)
        let addCompanyViewController = AddCompanyViewController(addCompanyViewModel: addCompanyViewModel,
                                                                navigationFromRegisterViewController: false)
        addCompanyViewController.isPresentedViewController = true
        let navigationController = UINavigationController(rootViewController: addCompanyViewController)
        viewController.present(navigationController, animated: true)
    }
    
    func navigateToChangePersonalInfoViewController(from viewController: UIViewController) {
        let updatePersonalInfoNetworking = UpdatePersonalInfoNetworking()
        let updatePersonalInfoViewModel = UpdatePersonalInfoViewModel(updatePersonalInfoNetworking: updatePersonalInfoNetworking)
        let updatePersonalInfoViewController = UpdatePersonalInfoViewController(updatePersonalInfoViewModel: updatePersonalInfoViewModel)
        viewController.navigationController?.pushViewController(updatePersonalInfoViewController, animated: true)
    }
    
    func navigateToChangePasswordViewController(from viewController: UIViewController) {
        let changePasswordNetworking = ChangePasswordNetworking()
        let changePasswordViewModel = ChangePasswordViewModel(changePasswordNetworking: changePasswordNetworking)
        let changePasswordViewController = ChangePasswordViewController(changePasswordViewModel: changePasswordViewModel)
        viewController.navigationController?.pushViewController(changePasswordViewController, animated: true)
    }
    
    func navigateToAdCompanyViewController(from viewController: UIViewController) {
        let companyNetworking = CompanyNetworking()
        let addCompanyViewModel = AddCompanyViewModel(companyNetworking: companyNetworking,
                                                      registeredUserEmail: SessionManager.shared.currentUser?.email)
        let addCompanyViewController = AddCompanyViewController(addCompanyViewModel: addCompanyViewModel,
                                                                navigationFromRegisterViewController: false)
        addCompanyViewController.navigationFromSettingsViewController = true
        viewController.navigationController?.pushViewController(addCompanyViewController, animated: true)
    }
}
