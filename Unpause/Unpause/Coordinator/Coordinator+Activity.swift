//
//  Coordinator+Activity.swift
//  Unpause
//
//  Created by Krešimir Baković on 26/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

extension Coordinator {
    func presentAddBossInfoViewController(from viewController: UIViewController) {
        let bossInfoViewModel = BossInfoViewModel()
        let bossInfoViewController = BossInfoViewController(bossInfoViewModel: bossInfoViewModel)
        viewController.present(bossInfoViewController, animated: true)
    }
}
