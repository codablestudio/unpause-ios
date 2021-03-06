//
//  CustomButton.swift
//  Unpause
//
//  Created by Krešimir Baković on 20/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit

class OrangeButton: UIButton {
    
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
        backgroundColor = UIColor.unpauseOrange
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.init(white: 1, alpha: 0.7), for: .highlighted)
    }
}
