//
//  CustomButton.swift
//  Unpause
//
//  Created by Krešimir Baković on 20/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit

class SettingsButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setUpButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpButton() {
        layer.cornerRadius = 5
        backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.4745098039, blue: 0.2078431373, alpha: 1)
    }
}
