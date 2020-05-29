//
//  Coordinator+UserType.swift
//  Unpause
//
//  Created by Krešimir Baković on 29/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func navigateToMapViewController(from viewController: UIViewController) {
        let mapViewModel = MapViewModel()
        let mapViewController = MapViewController(mapViewModel: mapViewModel)
        viewController.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func navigateToAddCompanyViewController(from viewController: UIViewController) {
        let companyNetworking = CompanyNetworking()
        let addCompanyViewModel = AddCompanyViewModel(companyNetworking: companyNetworking,
                                                      registeredUserEmail: SessionManager.shared.currentUser?.email)
        let addCompanyViewController = AddCompanyViewController(addCompanyViewModel: addCompanyViewModel,
                                                                navigationFromRegisterViewController: false)
        addCompanyViewController.navigationFromSettingsViewController = true
        viewController.navigationController?.pushViewController(addCompanyViewController, animated: true)
    }
}
