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
        let inAppPurchaseNetworking = InAppPurchaseNetworking()
        let upgradeToProViewModel = UpgradeToProViewModel(inAppPurchaseNetworking: inAppPurchaseNetworking)
        let upgradeToProViewController = UpgradeToProViewController(upgradeToProViewModel: upgradeToProViewModel)
        let navigatioController = UINavigationController(rootViewController: upgradeToProViewController)
        viewController.present(navigatioController, animated: true)
    }
}
