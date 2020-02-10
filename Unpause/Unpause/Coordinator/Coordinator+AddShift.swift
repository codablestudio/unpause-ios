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
    func navigateToDecriptionViewController(from viewController: UIViewController) {
        let descriptionViewModel = DescriptionViewModel()
        let descriptionViewController = DescriptionViewController(descriptionViewModel: descriptionViewModel)
        viewController.navigationController?.pushViewController(descriptionViewController, animated: true)
    }
}
