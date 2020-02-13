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

extension UIButton {
    func startAnimating(_ style: UIActivityIndicatorView.Style?) {
        titleLabel?.alpha = 0
        _ = subviews.map({ ($0 as? UIActivityIndicatorView)?.removeFromSuperview() })
        let activityIndicator = UIActivityIndicatorView(style: style ?? .gray)
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        activityIndicator.startAnimating()
    }
    func stopAnimating() {
        titleLabel?.alpha = 1
        _ = subviews.map({ ($0 as? UIActivityIndicatorView)?.removeFromSuperview() })
    }
}

import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    var animating: Binder<Bool> {
        return Binder(self.base) { button, isAnimating in
            if isAnimating {
                button.isEnabled = false
                button.startAnimating(.gray)
            } else {
                button.isEnabled = true
                button.stopAnimating()
            }
        }
    }
    
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { button, isEnabled in
            button.isEnabled = isEnabled
        }
    }
}
