//
//  UnpauseActivityIndicatorView.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class UnpauseActivityIndicatorView: UIActivityIndicatorView {
    
    static var shared = UnpauseActivityIndicatorView()
    
    let loadingView = UIView()
    let spinnerImageView = UIImageView()
    let unpauseLogoImageView = UIImageView()
    
    let successView = UIView()
    let successImageView = UIImageView()
    let successLabel = UILabel()
    
    func show(on view: UIView) {
        view.window?.addBlurEffect()
        view.window?.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        loadingView.backgroundColor = .clear
        loadingView.layer.cornerRadius = 40
        loadingView.clipsToBounds = true
        
        loadingView.addSubview(unpauseLogoImageView)
        unpauseLogoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        unpauseLogoImageView.image = UIImage(named: "unpause_white_logo_70x70")
        
        loadingView.addSubview(spinnerImageView)
        spinnerImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        spinnerImageView.image = UIImage(named: "unpause_spinner_70x70")
        
        spinnerImageView.rotate()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func showSuccessMessageAndDismissWithDelay(from view: UIView, successMessage: String, delay: Double) {
        loadingView.removeFromSuperview()
        view.window?.addSubview(successView)
        successView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
        successView.alpha = 0
        
        successView.addSubview(successImageView)
        successImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(80)
        }
        successImageView.image = UIImage(named: "success_80x80")
        
        successView.addSubview(successLabel)
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(successImageView.snp.bottom).offset(3)
            make.centerX.equalTo(successImageView.snp.centerX)
            make.bottom.equalToSuperview()
        }
        successLabel.text = successMessage
        successLabel.font = .systemFont(ofSize: 18, weight: .regular)
        fadeIn(viewToAnimate: successView, withDuration: 0.5) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let `self` = self else { return }
                self.successView.removeFromSuperview()
                view.window?.removeBlurEffect()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func dismiss(from view: UIView) {
        loadingView.removeFromSuperview()
        view.window?.removeBlurEffect()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
