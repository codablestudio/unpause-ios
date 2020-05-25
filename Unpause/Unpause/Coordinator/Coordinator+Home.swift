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
    
    func presentAddShiftViewController(from viewController: UIViewController, with shiftData: ShiftsTableViewItem) {
        let addShiftViewModel = AddShiftViewModel(cellToEdit: shiftData)
        let addShiftViewController = AddShiftViewController(addShiftViewModel: addShiftViewModel,
                                                            navigationFromTableView: true,
                                                            navigationFromCustomShift: false)
        addShiftViewController.cellToEdit = shiftData
        let navigationController = UINavigationController(rootViewController: addShiftViewController)
        navigationController.transitioningDelegate = viewController as? UIViewControllerTransitioningDelegate
        viewController.present(navigationController, animated: true)
    }
}
