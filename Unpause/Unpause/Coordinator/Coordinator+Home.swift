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
    func presentAddShiftViewController(from viewController: UIViewController, navigationFromCustomShift: Bool) {
        let addShiftViewModel = AddShiftViewModel()
        let addShiftViewController = AddShiftViewController(addShiftViewModel: addShiftViewModel,
                                                            navigationFromTableView: false,
                                                            navigationFromCustomShift: navigationFromCustomShift)
        let navigationController = UINavigationController(rootViewController: addShiftViewController)
        viewController.present(navigationController, animated: true)
    }
    
    func presentShiftViewController(from viewController: UIViewController) {
        let shiftNetworking = ShiftNetworking()
        let shiftViewModel = ShiftViewModel(shiftNetworking: shiftNetworking)
        let shiftViewController = ShiftViewController(shiftViewModel: shiftViewModel)
        let navigationController = UINavigationController(rootViewController: shiftViewController)
        viewController.present(navigationController, animated: true)
    }
    
    func presentCustomShiftViewController(from viewController: UIViewController) {
        let shiftNetworking = ShiftNetworking()
        let customShiftViewModel = CustomShiftViewModel(shiftNetworking: shiftNetworking)
        let customViewController = CustomShiftViewController(customShiftViewModel: customShiftViewModel)
        let navigationController = UINavigationController(rootViewController: customViewController)
        viewController.present(navigationController, animated: true)
    }
}
