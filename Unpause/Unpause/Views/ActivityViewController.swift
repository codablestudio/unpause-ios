//
//  ActivityViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    private let activityViewModel: ActivityViewModel
    
    
    init(activityViewModel: ActivityViewModel) {
        self.activityViewModel = activityViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        showTitleInNavigationBar()
    }
    
    private func render() {
        view.backgroundColor = UIColor(named: "white")
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Activity"
    }
}
