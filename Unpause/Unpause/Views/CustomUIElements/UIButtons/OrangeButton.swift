//
//  CustomButton.swift
//  Unpause
//
//  Created by Krešimir Baković on 20/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit

class OrangeButton: UIButton {
    
    init(title: String, height: CGFloat) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setUpButton(height: height)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpButton(height: CGFloat) {
        self.frame.size.height = height
        layer.cornerRadius = height / 2
        backgroundColor = UIColor.orange
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.init(white: 1, alpha: 0.7), for: .highlighted)
    }
}
