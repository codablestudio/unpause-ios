//
//  Coordinator+Register.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func navigateToAddCompanyViewController(from viewController: UIViewController, registeredUserEmail: String?) {
        let companyNetworking = CompanyNetworking()
        let addCompanyViewModel = AddCompanyViewModel(companyNetworking: companyNetworking,
                                                      registeredUserEmail: registeredUserEmail)
        let addCompanyViewController = AddCompanyViewController(addCompanyViewModel: addCompanyViewModel)
        viewController.navigationController?.pushViewController(addCompanyViewController, animated: true)
    }
}
