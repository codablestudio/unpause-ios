//
//  Coordinator+UpradeToPro.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func presentUpgradeToProViewController(from viewController: UIViewController) {
        let upgradeToProViewModel = UpgradeToProViewModel()
        let upgradeToProViewController = UpgradeToProViewController(upgradeToProViewModel: upgradeToProViewModel)
        let navigationController = UINavigationController(rootViewController: upgradeToProViewController)
        viewController.present(navigationController, animated: true)
    }
}
