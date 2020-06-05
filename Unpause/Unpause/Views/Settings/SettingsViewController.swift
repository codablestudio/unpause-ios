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
    
    private var dataSource: [SettingTableViewItem] = [.changePersonalInfo, .changePassword, .changeCompany, .addLocation, .logOut]
    
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
        showTitleInNavigationBar()
        setUpTableView()
    }
    
    private func render() {
        configureContainerView()
        configureTableView()
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Settings"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        removeLocationCellIfNeeded()
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
    
    private func removeLocationCellIfNeeded() {
        if SessionManager.shared.currentUserHasConnectedCompany() {
            var newDataSource: [SettingTableViewItem] = []
            for cell in dataSource {
                switch cell {
                case .addLocation:
                    print("Add location cell.")
                default:
                    newDataSource.append(cell)
                }
            }
            dataSource = newDataSource
        }
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
            Coordinator.shared.navigateToAddCompanyViewController(from: self)
        case .addLocation:
            Coordinator.shared.navigateToMapViewController(from: self)
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
            cell.configure(name: "Change personal info", thumbnailImageName: "user_30x30_black")
            return cell
        case .changePassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                     for: indexPath) as! SettingsTableViewCell
            cell.configure(name: "Change password", thumbnailImageName: "password_30x30_black")
            return cell
            
        case .changeCompany:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                     for: indexPath) as! SettingsTableViewCell
            let cellTitle = makeTitleForCompanyCell()
            cell.configure(name: cellTitle, thumbnailImageName: "company_30x30_black")
            return cell
        case .addLocation:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
            for: indexPath) as! SettingsTableViewCell
            cell.configure(name: "Manage locations", thumbnailImageName: "location_30_30_black")
            return cell
        case .logOut:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self),
                                                     for: indexPath) as! SettingsTableViewCell
            cell.configure(name: "Log out", thumbnailImageName: "logOut_30x30_black")
            return cell
        }
    }
    
    private func makeTitleForCompanyCell() -> String {
        if SessionManager.shared.currentUserHasConnectedCompany() {
            return "Change company"
        } else {
            return "Add company"
        }
    }
}
