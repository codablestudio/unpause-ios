//
//  HomeViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyStoreKit

class HomeViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let homeViewModel: HomeViewModelProtocol
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    let signedInLabel = UILabel()
    
    private let emailLabel = UILabel()
    private let userEmailLabel = UILabel()
    
    private let firstNameLabel = UILabel()
    private let userFirstNameLabel = UILabel()
    
    private let lastNameLabel = UILabel()
    private let userLastNameLabel = UILabel()
    
    private let companyLabel = UILabel()
    private let userCompanyLabel = UILabel()
    
    let checkInButton = UIButton()
    
    var userChecksIn = PublishSubject<Bool>()
    
    init(homeViewModel: HomeViewModelProtocol) {
        self.homeViewModel = homeViewModel
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
        IAPManager.shared.checkAndSaveOneMonthAutoRenewingSubscriptionValidationDate()
        IAPManager.shared.checkAndSaveOneYearAutoRenewingSubscriptionValidationDate()
        showUpgradeToProViewControllerIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayFreshUserData()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderSignedInLabel()
        renderEmailLabelAndUserEmailLabel()
        renderFirstNameLabelAndUserFirstNameLabel()
        renderLastNameLabelAndUserLastNameLabel()
        renderCompanyLabelAndUserCompanyLabel()
        renderCheckInButton()
    }
    
    func setUpObservables() {
        userChecksIn
            .do(onNext: { [weak self] (userChecksIn) in
                guard let `self` = self else { return }
                if !userChecksIn {
                    Coordinator.shared.presentAddShiftViewController(from: self, navigationFromCustomShift: false)
                }
            })
            .bind(to: homeViewModel.userChecksIn)
            .disposed(by: disposeBag)
        
        homeViewModel.fetchingLastShift
            .bind(to: checkInButton.rx.animating)
            .disposed(by: disposeBag)
        
        checkInButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if self.checkInButton.title(for: .normal) == "Check in" {
                    self.checkInButton.setTitle("Check out", for: .normal)
                    self.userChecksIn.onNext(true)
                } else {
                    self.userChecksIn.onNext(false)
                }
            }).disposed(by: disposeBag)
        
        NotificationManager.shared.userChecksIn
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.checkInButton.sendActions(for: .touchUpInside)
            }).disposed(by: disposeBag)
        
        homeViewModel.checkInResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    print("User successfully checked in.")
                    NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnEntry"])
                    NotificationManager.shared.scheduleExitNotification()
                    ActivityViewModel.forceRefresh.onNext(())
                case .error(let error):
                    self.showOneOptionAlert(title: "Error", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        homeViewModel.usersLastCheckInTimeRequest
            .subscribe(onNext: { [weak self] lastCheckInResponse in
                guard let `self` = self else { return }
                switch lastCheckInResponse {
                case .success(let lastCheckInDate):
                    SessionManager.shared.currentUser?.lastCheckInDateAndTime = lastCheckInDate
                    if lastCheckInDate != nil {
                        NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnEntry"])
                        NotificationManager.shared.scheduleExitNotification()
                        self.checkInButton.setTitle("Check out", for: .normal)
                    } else {
                        NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnExit"])
                        NotificationManager.shared.scheduleEntranceNotification()
                        self.checkInButton.setTitle("Check in", for: .normal)
                    }
                case .error(let error):
                    print("\(error)")
                }
            }).disposed(by: disposeBag)
    }
    
    private func showUpgradeToProViewControllerIfNeeded() {
        if !userIsPromoUserOrHasValidSubscription() {
            Coordinator.shared.presentUpgradeToProViewController(from: self)
        }
    }
    
    private func userIsPromoUserOrHasValidSubscription() -> Bool {
        if let userMonthSubscriptionEndingDate = SessionManager.shared.currentUser?.monthSubscriptionEndingDate,
            userMonthSubscriptionEndingDate > Date() {
            return true
        }
        else if let userYearSubscriptionEndingDate = SessionManager.shared.currentUser?.yearSubscriptionEndingDate,
            userYearSubscriptionEndingDate > Date() {
            return true
        }
        else if let userIsPromoUser = SessionManager.shared.currentUser?.isPromoUser,
            userIsPromoUser {
            return true
        } else {
            return false
        }
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Home"
    }
    
    private func displayFreshUserData() {
        userFirstNameLabel.text = SessionManager.shared.currentUser?.firstName ?? "No first name"
        userLastNameLabel.text = SessionManager.shared.currentUser?.lastName ?? "No last name"
        userCompanyLabel.text = SessionManager.shared.currentUser?.company?.name ?? "No company"
    }
}

// MARK: - UI rendering
private extension HomeViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
        }
    }
    
    func renderSignedInLabel() {
        containerView.addSubview(signedInLabel)
        
        signedInLabel.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview().offset(UIScreen.main.bounds.height / 10)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview()
        }
        signedInLabel.text = "Signed in as:"
        signedInLabel.font = UIFont.boldSystemFont(ofSize: 23)
    }
    
    func renderEmailLabelAndUserEmailLabel() {
        containerView.addSubview(emailLabel)
        emailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signedInLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
        }
        emailLabel.text = "Email:"
        emailLabel.textColor = UIColor.unpauseLightGray
        
        containerView.addSubview(userEmailLabel)
        userEmailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signedInLabel.snp.bottom).offset(20)
            make.left.equalTo(emailLabel.snp.right).offset(7)
            make.right.equalToSuperview()
        }
        userEmailLabel.text = SessionManager.shared.currentUser?.email ?? "No user"
        userEmailLabel.textColor = UIColor.unpauseLightGray
    }
    
    func renderFirstNameLabelAndUserFirstNameLabel() {
        containerView.addSubview(firstNameLabel)
        firstNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emailLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
        }
        firstNameLabel.text = "First name:"
        firstNameLabel.textColor = UIColor.unpauseLightGray
        
        containerView.addSubview(userFirstNameLabel)
        userFirstNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emailLabel.snp.bottom).offset(20)
            make.left.equalTo(firstNameLabel.snp.right).offset(7)
            make.right.equalToSuperview()
        }
        userFirstNameLabel.text = SessionManager.shared.currentUser?.firstName ?? "No first name"
        userFirstNameLabel.textColor = UIColor.unpauseLightGray
    }
    
    func renderLastNameLabelAndUserLastNameLabel() {
        containerView.addSubview(lastNameLabel)
        lastNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
        }
        lastNameLabel.text = "Last name:"
        lastNameLabel.textColor = UIColor.unpauseLightGray
        
        containerView.addSubview(userLastNameLabel)
        userLastNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameLabel.snp.bottom).offset(20)
            make.left.equalTo(lastNameLabel.snp.right).offset(7)
            make.right.equalToSuperview()
        }
        userLastNameLabel.text = SessionManager.shared.currentUser?.lastName ?? "No last name"
        userLastNameLabel.textColor = UIColor.unpauseLightGray
    }
    
    func renderCompanyLabelAndUserCompanyLabel() {
        containerView.addSubview(companyLabel)
        companyLabel.snp.makeConstraints { make in
            make.top.equalTo(lastNameLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
        }
        companyLabel.text = "Company:"
        companyLabel.textColor = UIColor.unpauseLightGray
        
        containerView.addSubview(userCompanyLabel)
        userCompanyLabel.snp.makeConstraints { make in
            make.top.equalTo(lastNameLabel.snp.bottom).offset(20)
            make.left.equalTo(companyLabel.snp.right).offset(7)
            make.right.equalToSuperview()
        }
        userCompanyLabel.text = SessionManager.shared.currentUser?.company?.name ?? "No company"
        userCompanyLabel.textColor = UIColor.unpauseLightGray
    }
    
    func renderCheckInButton() {
        containerView.addSubview(checkInButton)
        checkInButton.snp.makeConstraints { (make) in
            make.top.equalTo(companyLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(140)
            make.width.equalTo(140)
            make.bottom.equalToSuperview()
        }
        checkInButton.backgroundColor = UIColor.unpauseOrange
        checkInButton.layer.cornerRadius = 70
        checkInButton.titleLabel?.font = .systemFont(ofSize: 25)
        checkInButton.setTitleColor(.white, for: UIControl.State())
        checkInButton.dropShadow(color: .unpauseLightGray, opacity: 0.5, offSet: .zero, radius: 5)
    }
}
