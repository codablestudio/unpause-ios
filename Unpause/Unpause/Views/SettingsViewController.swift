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
    private let settingsViewModel: SettingsViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let changePersonalInfoButton = OrangeButton(title: "Change personal info")
    private let changePasswordButton = OrangeButton(title: "Change password")
    private let addCompanyButton = OrangeButton(title: "Add company")
    private let logOutButton = OrangeButton(title: "Log out")
    
    init(settingsViewModel: SettingsViewModel) {
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
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderChangePersonalInfoButton()
        renderChangePasswordButton()
        renderAddCompanyButton()
        renderLogOutButton()
    }
    
    private func setUpObservables() {
        changePersonalInfoButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            Coordinator.shared.presentChangePersonalInfoViewController(from: self)
        }).disposed(by: disposeBag)
        
        changePasswordButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            Coordinator.shared.presentChangePasswordViewController(from: self)
        }).disposed(by: disposeBag)
        
        addCompanyButton.rx.tap.subscribe(onNext: { _ in
            Coordinator.shared.presentAddCompanyViewController(from: self)
        }).disposed(by: disposeBag)
        
        logOutButton.rx.tap.bind(to: settingsViewModel.logOutButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Settings"
    }
}

// MARK: - UI rendering
private extension SettingsViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.whiteUnpauseTextAndBackgroundColor
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
        }
    }
    
    func renderChangePersonalInfoButton() {
        containerView.addSubview(changePersonalInfoButton)
        changePersonalInfoButton.snp.makeConstraints { make in
            make.topMargin.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        changePersonalInfoButton.layer.cornerRadius = 25
    }
    
    func renderChangePasswordButton() {
        containerView.addSubview(changePasswordButton)
        changePasswordButton.snp.makeConstraints { make in
            make.top.equalTo(changePersonalInfoButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        changePasswordButton.layer.cornerRadius = 25
    }
    
    func renderAddCompanyButton() {
        containerView.addSubview(addCompanyButton)
        addCompanyButton.snp.makeConstraints { make in
            make.top.equalTo(changePasswordButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        addCompanyButton.layer.cornerRadius = 25
    }
    
    func renderLogOutButton() {
        containerView.addSubview(logOutButton)
        logOutButton.snp.makeConstraints { make in
            make.top.equalTo(addCompanyButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        logOutButton.layer.cornerRadius = 25
    }
}
