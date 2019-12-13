//
//  UIStackView+Extension.swift

//
//  Created by Marko Aras on 03/04/2019.
//  Copyright © 2019 Codable Studio. All rights reserved.
//

import UIKit

extension UIStackView {
    func addBackground(color: UIColor) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subview, at: 0)
    }
}
