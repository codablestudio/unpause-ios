//
//  UIView+Extension.swift

//
//  Created by Marko Aras on 19/11/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import UIKit
import SnapKit

enum BorderViewTag: Int {
    case right = 3
    case bottom = 4
}

extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
    }
    
    func addTopBorder(_ color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0) {
        let border = UIView()
        addSubview(border)
        border.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftOffset)
            make.right.equalToSuperview().offset(rightOffset)
            make.top.equalToSuperview()
            make.height.equalTo(1)
        }
        border.backgroundColor = color
    }
    
    func addNavigationBottomBorder() {
        let border = UIView()
        border.backgroundColor = .red
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.equalToSuperview()
        }
    }
    
    @objc func addBottomBorder(_ color: UIColor, height: Int = 1, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0) {
        removeBorder(.bottom)
        let border = UIView()
        border.tag = BorderViewTag.bottom.rawValue
        addSubview(border)
        border.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftOffset)
            make.right.equalToSuperview().offset(rightOffset)
            make.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
        border.backgroundColor = color
    }
    
    func removeBorder(_ tag: BorderViewTag) {
        self.subviews.forEach { view in
            if view.tag == tag.rawValue {
                view.removeFromSuperview()
            }
        }
    }
    
    func hasBorder(_ tag: BorderViewTag) -> Bool {
        return subviews.first(where: { $0.tag == tag.rawValue }) != nil
    }
    
    func colorBorder(_ tag: BorderViewTag, color: UIColor) {
        self.subviews.forEach { view in
            if view.tag == tag.rawValue {
                view.backgroundColor = color
            }
        }
    }
    
    func addRightBorder(_ color: UIColor, width: Int = 1) {
        removeBorder(.bottom)
        let border = UIView()
        border.tag = BorderViewTag.right.rawValue
        addSubview(border)
        border.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(width)
        }
        border.backgroundColor = color
    }
    
    func getStatusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    func safeBottomInset() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    /// returns safeBottomInset if > 0, else return returns 10
    func safeButtonBottomInset() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        let bottom = window?.safeAreaInsets.bottom ?? 0
        return bottom > 0 ? bottom : 10
    }
}

// MARK: - SnapKit
extension UIView {
    func edgesEqualToSuperview(insets: UIEdgeInsets = UIEdgeInsets.zero) {
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(insets)
        }
    }
    
    func widthEqualToSuperview() {
        self.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
        }
    }
    
    func heightEqualToSuperview() {
        self.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
        }
    }
}

// MARK: - rounded Corners
extension UIView {
    func roundedAllCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius
        if #available(iOS 11, *) {
            self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                    .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
        }
    }
    
    func roundedTopCorners(radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        } else {
            addMask(top: true, radius: radius)
        }
    }
    
    func roundedBottomCorners(radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
        } else {
            addMask(top: false, radius: radius)
        }
    }
    
    func addMask(top: Bool, radius: CGFloat) {
        let roundedView = UIView()
        let hidingExcesCornersMask = UIView()
        
        roundedView.isUserInteractionEnabled = false
        hidingExcesCornersMask.isUserInteractionEnabled = false
        
        insertSubview(roundedView, at: 0)
        roundedView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        roundedView.layer.cornerRadius = radius
        
        insertSubview(hidingExcesCornersMask, aboveSubview: roundedView)
        hidingExcesCornersMask.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if top {
                make.bottom.equalToSuperview()
            } else {
                make.top.equalToSuperview()
            }
            make.height.equalTo(radius)
        }
        
        roundedView.backgroundColor = self.backgroundColor
        hidingExcesCornersMask.backgroundColor = self.backgroundColor
        self.backgroundColor = .clear
    }
    
    func addMask(left: Bool, radius: CGFloat) {
        let roundedView = UIView()
        let hidingExcesCornersMask = UIView()
        
        roundedView.isUserInteractionEnabled = false
        hidingExcesCornersMask.isUserInteractionEnabled = false
        
        insertSubview(roundedView, at: 0)
        roundedView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        roundedView.layer.cornerRadius = radius
        
        insertSubview(hidingExcesCornersMask, aboveSubview: roundedView)
        hidingExcesCornersMask.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            if left {
                make.left.equalToSuperview()
            } else {
                make.right.equalToSuperview()
            }
            make.width.equalTo(radius)
        }
        
        roundedView.backgroundColor = self.backgroundColor
        hidingExcesCornersMask.backgroundColor = self.backgroundColor
        self.backgroundColor = .clear
    }
    
    func addMask(right: Bool, radius: CGFloat) {
        let roundedView = UIView()
        let hidingExcesCornersMask = UIView()
        
        roundedView.isUserInteractionEnabled = false
        hidingExcesCornersMask.isUserInteractionEnabled = false
        
        insertSubview(roundedView, at: 0)
        roundedView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        roundedView.layer.cornerRadius = radius
        
        insertSubview(hidingExcesCornersMask, aboveSubview: roundedView)
        hidingExcesCornersMask.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            if right {
                make.left.equalToSuperview()
            } else {
                make.right.equalToSuperview()
            }
            make.width.equalTo(radius)
        }
        
        roundedView.backgroundColor = self.backgroundColor
        hidingExcesCornersMask.backgroundColor = self.backgroundColor
        self.backgroundColor = .clear
    }
    
    func roundedLeftCorners(radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMinXMaxYCorner)
        } else {
            addMask(left: true, radius: radius)
        }
    }
    
    func roundedRightCorners(radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMinYCorner, .layerMaxXMaxYCorner)
        } else {
            addMask(right: true, radius: radius)
        }
    }
}

// MARK: - Loader
extension UIView {
    func renderLoader(_ style: UIActivityIndicatorView.Style = .gray) {
        _ = subviews.map({ ($0 as? UIActivityIndicatorView)?.removeFromSuperview() })
        let activityIndicator = UIActivityIndicatorView(style: style)
        self.subviews.forEach({ $0.isHidden = true })
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        activityIndicator.startAnimating()
        
        if let btn = self as? UIButton {
            btn.isEnabled = false
            btn.titleLabel?.alpha = 0
        }
    }
    
    func removeLoader() {
        _ = subviews.map({ ($0 as? UIActivityIndicatorView)?.removeFromSuperview() })
        self.subviews.forEach({ $0.isHidden = false })
        
        if let btn = self as? UIButton {
            btn.isEnabled = true
            btn.titleLabel?.alpha = 1
        }
    }
}

extension UIView {
    func animateLikeButton() {
        let transform: CGAffineTransform = .init(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3, options: [.curveEaseInOut],
                       animations: { self.transform = transform })
        
        animateBack()
    }
    
    private func animateBack() {
        let transform: CGAffineTransform = .identity
        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3, options: [.curveEaseInOut],
                       animations: { self.transform = transform })
    }
    
    func addGradient() {
        let backgroundImageViewGradient = UIImageView(image: UIImage.create("Gradient"))
        self.addSubview(backgroundImageViewGradient)
        backgroundImageViewGradient.edgesEqualToSuperview()
    }
    
    func addBlackOverlay() {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.addSubview(view)
        view.edgesEqualToSuperview()
    }
}

// MARK: - Rotate animation
extension UIView {
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

// MARK: - Blur effect
extension UIView {
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
}
