//
//  ActivityIndicatorView.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIActivityIndicatorView {
    
    static var shared = ActivityIndicatorView()
    
    let loadingView = UIView()
    
    func show(on view: UIView) {
        loadingView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        loadingView.center = view.center
        loadingView.backgroundColor = .unpauseIndicatorGray
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        self.center = view.center
        self.hidesWhenStopped = true
        self.color = .white
        self.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(self)
        view.addSubview(loadingView)
        self.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func dissmis() {
        self.stopAnimating()
        loadingView.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
