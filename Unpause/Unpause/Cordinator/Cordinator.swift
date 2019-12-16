//
//  Cordinator.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

class Cordinator: UIViewController {
    
    func navigateTo(uiViewController: UIViewController) {
        navigationController?.pushViewController(uiViewController, animated: true)
    }
}
