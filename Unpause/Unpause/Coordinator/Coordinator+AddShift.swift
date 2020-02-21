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
    func navigateToDecriptionViewController(from viewController: UIViewController, arrivalTime: Date?, leavingTime: Date?) {
        let descriptionViewModel = DescriptionViewModel(arrivalDateAndTime: arrivalTime, leavingDateAndTime: leavingTime)
        let descriptionViewController = DescriptionViewController(descriptionViewModel: descriptionViewModel, navigationFromTableView: false)
        viewController.navigationController?.pushViewController(descriptionViewController, animated: true)
    }
    
    func navigateToDecriptionViewController(from viewController: UIViewController, arrivalTime: Date?, leavingTime: Date?, with shiftData: ShiftsTableViewItem) {
        let descriptionViewModel = DescriptionViewModel(arrivalDateAndTime: arrivalTime, leavingDateAndTime: leavingTime)
        let descriptionViewController = DescriptionViewController(descriptionViewModel: descriptionViewModel, navigationFromTableView: true)
        viewController.navigationController?.pushViewController(descriptionViewController, animated: true)
    }
}
