//
//  UIButton+Extension.swift

//
//  Created by Marko Aras on 18/09/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import UIKit

extension UIButton {
    /**
     set title label font, and setTitleColor for .normal
     */
    func setFontAndColor(font: UIFont, color: UIColor) {
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = font
    }

    func addBorder(color: UIColor, width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }

    func addBottomBorder(color: UIColor, height: CGFloat) {
        let border = UIView()
        border.snp.makeConstraints { (make) in
            make.height.equalTo(height)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        border.backgroundColor = color
    }
}
