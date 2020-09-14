//
//  Coordinator+Calendar.swift
//  Unpause
//
//  Created by Krešimir Baković on 14/09/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func presentCalendarViewController(from viewController: UIViewController, calendarViewController: CalendarViewController) {
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        viewController.present(navigationController, animated: true)
    }
}
