//
//  DotsBarButton.swift
//  Unpause
//
//  Created by Krešimir Baković on 17/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

class DotsUIBarButtonItem: UIBarButtonItem {
    
    override init() {
        super.init()
        setUpButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpButton() {
        style = .plain
        target = self
        image = UIImage(named: "three_dots_30x30_black")
        tintColor = .unpauseBlack
    }
}
