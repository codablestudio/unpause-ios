//
//  Coordinator+Home.swift
//  Unpause
//
//  Created by Krešimir Baković on 15/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func presentAddShiftViewController(from viewController: UIViewController) {
        let addShiftViewModel = AddShiftViewModel()
        let addShiftViewController = AddShiftViewController(addShiftViewModel: addShiftViewModel)
        let navigationController = UINavigationController(rootViewController: addShiftViewController)
        viewController.present(navigationController, animated: true)
    }
}