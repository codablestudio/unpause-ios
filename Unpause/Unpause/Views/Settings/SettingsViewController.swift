//
//  SettingsViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class SettingsViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let settingsViewModel: SettingsViewModelProtocol
    
    private let containerView = UIView()
    
    private let tableView = UITableView()
    
    private let dataSource: [SettingTableViewItem] = [.changePersonalInfo, .changePassword, .changeCompany]
    
    init(settingsViewModel: SettingsViewModelProtocol) {
        self.settingsViewModel = settingsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        showTitleInNavigationBar()
        setUpTableView()
    }
    
    private func render() {
        configureContainerView()
        configureTableView()
    }
    
    private func setUpObservables() {
        
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Settings"
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    private func showTwoOptionAlert(title: String, message: String, actionTitle1: String, actionTitle2: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle1, style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: actionTitle2, style: .destructive, handler: { _ in
            SessionManager.shared.logOut()
            Coordinator.shared.logOut()
        }))
        self.present(alert, animated: true)
    }
}

// MARK: - UI rendering
private extension SettingsViewController {
    func configureContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        containerView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: - Table View Delegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch dataSource[indexPath.row] {
        case .changePersonalInfo:
            Coordinator.shared.navigateToChangePersonalInfoViewController(from: self)
        case .changePassword:
            Coordinator.shared.navigateToChangePasswordViewController(from: self)
        case .changeCompany:
            Coordinator.shared.navigateToAdCompanyViewController(from: self)
        case .logOut:
            self.showTwoOptionAlert(title: "Log out", message: "Are you sure you want to log out?", actionTitle1: "Cancel", actionTitle2: "Log out")
        }
    }
}

//MARK: - Table View DataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataSource[indexPath.row] {
        case .changePersonalInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                     for: indexPath) as! SettingsTableViewCell
            cell.configure(name: "Change personal info")
            return cell
        case .changePassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                     for: indexPath) as! SettingsTableViewCell
            cell.configure(name: "Change password")
            return cell
            
        case .changeCompany:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                     for: indexPath) as! SettingsTableViewCell
            cell.configure(name: "Change company")
            return cell
        case .logOut:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                     for: indexPath) as! SettingsTableViewCell
            cell.configure(name: "Log out")
            return cell
        }
    }
}
