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
    let spinner = UIImageView()
    let unpauseLogo = UIImageView()
    
    func show(on view: UIView) {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        loadingView.backgroundColor = .clear
        loadingView.clipsToBounds = true
        
        loadingView.addSubview(unpauseLogo)
        unpauseLogo.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        unpauseLogo.image = UIImage(named: "unpause_white_logo_70x70")
        
        loadingView.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        spinner.image = UIImage(named: "unpause_spinner_70x70")
        
        spinner.rotate()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func dissmis() {
        loadingView.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
