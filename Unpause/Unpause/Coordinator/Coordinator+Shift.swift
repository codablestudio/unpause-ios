//
//  Coordinator+Shift.swift
//  Unpause
//
//  Created by Krešimir Baković on 15/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
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
    
    func presentEditShiftViewController(from viewController: ActivityViewController, shiftToEdit: ShiftsTableViewItem) {
        let shiftNetworking = ShiftNetworking()
        let editShiftViewModel = EditShiftViewModel(shiftNetworking: shiftNetworking, shiftToEdit: shiftToEdit)
        let editShiftViewController = EditShiftViewController(editShiftViewModel: editShiftViewModel, shiftToEdit: shiftToEdit)
        let navigationController = UINavigationController(rootViewController: editShiftViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.transitioningDelegate = viewController
        viewController.present(navigationController, animated: true)
    }
}
