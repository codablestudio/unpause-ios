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
    
    private let userImageView = UIImageView()
    private let usernameLabel = UILabel()
    
    private let usernameSeparator = UIView()
    
    private let companyImageView = UIImageView()
    private let companyNameLabel = UILabel()
    
    private let companySeparator = UIView()
    
    let checkInButton = UIButton()
    
    private let lastCheckInTimeLabel = UILabel()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayFreshUserData()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderUserImageViewAndUsernameLabel()
        renderUsernameSeparator()
        renderCompanyImageViewAndCompanyNameLabel()
        renderCompanySeparator()
        renderCheckInButton()
        renderLastCheckInTimeLabel()
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
                vibratePhoneOnTouch()
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
                    self.displayFreshLastCheckInTime()
                    NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnEntry"])
                    NotificationManager.shared.scheduleExitNotification()
                    NotificationManager.shared.scheduleTwelveHourDelayNotification()
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
                    self.displayFreshLastCheckInTime()
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
    
    private func showTitleInNavigationBar() {
        self.title = "Home"
    }
    
    private func displayFreshUserData() {
        displayFreshUsernameData()
        displayFreshCompanyData()
    }
    
    private func displayFreshUsernameData() {
        if let firstName = SessionManager.shared.currentUser?.firstName,
            let lastName = SessionManager.shared.currentUser?.lastName {
            usernameLabel.text = "\(firstName) \(lastName)"
        } else {
            usernameLabel.text = "No user info"
        }
    }
    
    private func displayFreshCompanyData() {
        companyNameLabel.text = SessionManager.shared.currentUser?.company?.name ?? "No company"
    }
    
    private func displayFreshLastCheckInTime() {
        guard let lastCheckInTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime else {
            fadeOut(viewToAnimate: lastCheckInTimeLabel, withDuration: 0.4)
            return
        }
        fadeIn(viewToAnimate: lastCheckInTimeLabel, withDuration: 0.4)
        let lastCheckInTimeInStringFormat = Formatter.shared.convertDateIntoStringWithTime(from: lastCheckInTime)
        lastCheckInTimeLabel.text = "Last check in time: \(lastCheckInTimeInStringFormat)"
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
    
    func renderUserImageViewAndUsernameLabel() {
        containerView.addSubview(userImageView)
        userImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(30)
            make.height.width.equalTo(27)
        }
        userImageView.image = UIImage(named: "user_30x30_black")
        
        containerView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.bottom.equalTo(userImageView.snp.bottom).offset(1)
        }
        displayFreshUsernameData()
        usernameLabel.textColor = .unpauseBlack
        usernameLabel.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    func renderUsernameSeparator() {
        containerView.addSubview(usernameSeparator)
        usernameSeparator.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(25)
            make.height.equalTo(1)
        }
        usernameSeparator.backgroundColor = .unpauseVeryLightGray
    }
    
    func renderCompanyImageViewAndCompanyNameLabel() {
        containerView.addSubview(companyImageView)
        companyImageView.snp.makeConstraints { make in
            make.top.equalTo(usernameSeparator.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(30)
            make.height.width.equalTo(27)
        }
        companyImageView.image = UIImage(named: "company_30x30_black")
        
        containerView.addSubview(companyNameLabel)
        companyNameLabel.snp.makeConstraints { make in
            make.left.equalTo(companyImageView.snp.right).offset(10)
            make.bottom.equalTo(companyImageView.snp.bottom).offset(-1)
        }
        displayFreshCompanyData()
        companyNameLabel.textColor = .unpauseBlack
        companyNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    func renderCompanySeparator() {
        containerView.addSubview(companySeparator)
        companySeparator.snp.makeConstraints { make in
            make.top.equalTo(companyImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(25)
            make.height.equalTo(1)
        }
        companySeparator.backgroundColor = .unpauseVeryLightGray
    }
    
    func renderCheckInButton() {
        containerView.addSubview(checkInButton)
        checkInButton.snp.makeConstraints { (make) in
            make.top.equalTo(companySeparator.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(140)
            make.width.equalTo(140)
        }
        checkInButton.backgroundColor = UIColor.unpauseOrange
        checkInButton.layer.cornerRadius = 70
        checkInButton.titleLabel?.font = .systemFont(ofSize: 25)
        checkInButton.setTitleColor(.white, for: UIControl.State())
        checkInButton.dropShadow(color: .unpauseLightGray, opacity: 0.5, offSet: .zero, radius: 5)
    }
    
    func renderLastCheckInTimeLabel() {
        containerView.addSubview(lastCheckInTimeLabel)
        lastCheckInTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(checkInButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        lastCheckInTimeLabel.font = .systemFont(ofSize: 13, weight: .light)
        displayFreshLastCheckInTime()
    }
}

// MARK: - Animations
private extension HomeViewController {
    func fadeIn(viewToAnimate: UIView, withDuration duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.alpha = 1.0
        })
    }
    
    func fadeOut(viewToAnimate: UIView, withDuration duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.alpha = 0.0
        })
    }
}

// MARK: - Haptic feedback
func vibratePhoneOnTouch() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}
