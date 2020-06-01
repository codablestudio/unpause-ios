//
//  Coordinator+AddShift.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func navigateToDecriptionViewController(from viewController: UIViewController,
                                            arrivalTime: Date?,
                                            leavingTime: Date?,
                                            navigationFromCustomShift: Bool) {
        let shiftNetworking = ShiftNetworking()
        let descriptionViewModel = DescriptionViewModel(shiftNetworking: shiftNetworking,
                                                        arrivalDateAndTime: arrivalTime,
                                                        leavingDateAndTime: leavingTime,
                                                        navigationFromCustomShift: navigationFromCustomShift)
        let descriptionViewController = DescriptionViewController(descriptionViewModel: descriptionViewModel,
                                                                  navigationFromTableView: false)
        viewController.navigationController?.pushViewController(descriptionViewController, animated: true)
    }
    
    func navigateToDecriptionViewController(from viewController: UIViewController, arrivalTime: Date?, leavingTime: Date?, with shiftData: ShiftsTableViewItem) {
        let shiftNetworking = ShiftNetworking()
        let descriptionViewModel = DescriptionViewModel(shiftNetworking: shiftNetworking,
                                                        arrivalDateAndTime: arrivalTime,
                                                        leavingDateAndTime: leavingTime,
                                                        cellToEdit: shiftData)
        let descriptionViewController = DescriptionViewController(descriptionViewModel: descriptionViewModel,
                                                                  navigationFromTableView: true)
        descriptionViewController.cellToEdit = shiftData
        viewController.navigationController?.pushViewController(descriptionViewController, animated: true)
    }
}
