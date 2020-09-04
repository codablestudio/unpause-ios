//
//  Coordinator+Calendar.swift
//  Unpause
//
//  Created by Krešimir Baković on 04/09/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func presentCalendarViewController(from viewController: UIViewController) {
        let calendarViewModel = CalendarViewModel()
        let calendarViewController = CalendarViewController(viewModel: calendarViewModel)
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        viewController.present(navigationController, animated: true)
    }
}
