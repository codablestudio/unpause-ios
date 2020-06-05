//
//  UpgradeToProViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import StoreKit

class UpgradeToProViewController: UIViewController {
    
    private let upgradeToProViewModel: UpgradeToProViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let premiumFeaturesView = UIView()
    private let premiumFeaturesImageView = UIImageView()
    private let premiumFeaturesTitleLabel = UILabel()
    private let premiumFeaturesDescriptionLabel = UILabel()
    
    private let premiumFeaturesSeparator = UIView()
    
    private let notificationImageView = UIImageView()
    private let notificationTitleLabel = UILabel()
    private let notificationDescriptionLabel = UILabel()
    
    private let CSVImageView = UIImageView()
    private let CSVTitleLabel = UILabel()
    private let CSVDescriptionLabel = UILabel()
    
    private let sendEmailImageView = UIImageView()
    private let sendEmailTitleLabel = UILabel()
    private let sendEmailDescriptionLabel = UILabel()
    
    private let oneMonthSubscriptionLabel = UILabel()
    private let oneMonthSubscriptionButton = UIButton()
    
    private let oneYearSubscriptionLabel = UILabel()
    private let oneYearSubscriptionButton = UIButton()
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
    init(upgradeToProViewModel: UpgradeToProViewModelProtocol) {
        self.upgradeToProViewModel = upgradeToProViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        setUpViewControllerTitle()
        setUpSKPayment()
        addBarButtonItem()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderPremiumFeaturesViewAndItsSubviews()
        renderSeparator()
        renderNotificationImageView()
        renderNotificationTitleLabel()
        renderNotificationDescriptionLabel()
        renderCSVImageView()
        renderCSVTitleLabel()
        renderCSVDescriptionLabel()
        renderSendEmailImageView()
        renderSendEmailTitleLabel()
        renderSendEmailDescriptionLabel()
        renderOneMonthSubscriptionLabel()
        renderOneMontSubscriptionButton()
        renderOneYearSubscriptionLabel()
        renderOneYearSubscriptionButton()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        oneMonthSubscriptionButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if SKPaymentQueue.canMakePayments() {
                    UnpauseActivityIndicatorView.shared.show(on: self.view)
                    let paymentRequest = SKMutablePayment()
                    paymentRequest.productIdentifier = IAPManager.shared.oneMonthSubscriptionProductID
                    SKPaymentQueue.default().add(paymentRequest)
                } else {
                    self.showOneOptionAlert(title: "Payment alert", message: "You are unable to make payments.", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        oneYearSubscriptionButton.rx.tap
        .subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if SKPaymentQueue.canMakePayments() {
                UnpauseActivityIndicatorView.shared.show(on: self.view)
                let paymentRequest = SKMutablePayment()
                paymentRequest.productIdentifier = IAPManager.shared.oneYearSubscriptionProductID
                SKPaymentQueue.default().add(paymentRequest)
            } else {
                self.showOneOptionAlert(title: "Payment alert", message: "You are unable to make payments.", actionTitle: "OK")
            }
        }).disposed(by: disposeBag)
    }
    
    private func setUpViewControllerTitle() {
        self.title = "Pro version"
    }
    
    private func setUpSKPayment() {
        SKPaymentQueue.default().add(self)
    }
    
    private func addBarButtonItem() {
        navigationItem.leftBarButtonItem = closeButton
    }
}

// MARK: - UI rendering
private extension UpgradeToProViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func renderPremiumFeaturesViewAndItsSubviews() {
        containerView.addSubview(premiumFeaturesView)
        premiumFeaturesView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(100)
        }
        premiumFeaturesView.backgroundColor = .unpauseGreen
        premiumFeaturesView.layer.cornerRadius = 15
        
        premiumFeaturesView.addSubview(premiumFeaturesImageView)
        premiumFeaturesImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(7)
            make.width.height.equalTo(60)
        }
        premiumFeaturesImageView.image = UIImage(named: "unpausePro_60x60_white")
        premiumFeaturesImageView.contentMode = .scaleAspectFit
        
        premiumFeaturesView.addSubview(premiumFeaturesTitleLabel)
        premiumFeaturesTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalTo(premiumFeaturesImageView.snp.right).offset(8)
            make.right.equalToSuperview()
        }
        premiumFeaturesTitleLabel.text = "Premium Features"
        premiumFeaturesTitleLabel.textColor = .white
        premiumFeaturesTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        premiumFeaturesView.addSubview(premiumFeaturesDescriptionLabel)
        premiumFeaturesDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(premiumFeaturesTitleLabel.snp.bottom).offset(2)
            make.left.equalTo(premiumFeaturesImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(15)
        }
        premiumFeaturesDescriptionLabel.numberOfLines = 0
        premiumFeaturesDescriptionLabel.textColor = .white
        premiumFeaturesDescriptionLabel.text = "Unlock them and make your prefessional career moments easier to manage and track."
        premiumFeaturesDescriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    func renderSeparator() {
        containerView.addSubview(premiumFeaturesSeparator)
        premiumFeaturesSeparator.snp.makeConstraints { make in
            make.top.equalTo(premiumFeaturesView.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(45)
            make.right.equalToSuperview().inset(45)
            make.height.equalTo(1)
        }
        premiumFeaturesSeparator.backgroundColor = .unpauseVeryLightGray
    }
    
    func renderNotificationImageView() {
        containerView.addSubview(notificationImageView)
        notificationImageView.snp.makeConstraints { make in
            make.top.equalTo(premiumFeaturesSeparator.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(25)
            make.height.width.equalTo(80)
        }
        notificationImageView.image = UIImage(named: "notification_80x80")
        notificationImageView.contentMode = .scaleAspectFit
    }
    
    func renderNotificationTitleLabel() {
        containerView.addSubview(notificationTitleLabel)
        notificationTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(premiumFeaturesSeparator.snp.bottom).offset(30)
            make.left.equalTo(notificationImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(25)
        }
        notificationTitleLabel.text = "Notifications"
        notificationTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        notificationTitleLabel.numberOfLines = 0
    }
    
    func renderNotificationDescriptionLabel() {
        containerView.addSubview(notificationDescriptionLabel)
        notificationDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(notificationTitleLabel.snp.bottom).offset(2)
            make.left.equalTo(notificationImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(25)
        }
        notificationDescriptionLabel.numberOfLines = 0
        notificationDescriptionLabel.textColor = .unpauseLightGray
        notificationDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        notificationDescriptionLabel.text = "Location will be triggered every time you arrive or leave your job‘s area. You can check in through notification service."
    }
    
    func renderCSVImageView() {
        containerView.addSubview(CSVImageView)
        CSVImageView.snp.makeConstraints { make in
            make.top.equalTo(notificationDescriptionLabel.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(25)
            make.height.width.equalTo(80)
        }
        CSVImageView.image = UIImage(named: "csv_80x80")
        CSVImageView.contentMode = .scaleAspectFit
    }
    
    func renderCSVTitleLabel() {
        containerView.addSubview(CSVTitleLabel)
        CSVTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(notificationDescriptionLabel.snp.bottom).offset(30)
            make.left.equalTo(CSVImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(25)
        }
        CSVTitleLabel.text = "CSV format export"
        CSVTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        CSVTitleLabel.numberOfLines = 0
    }
    
    func renderCSVDescriptionLabel() {
        containerView.addSubview(CSVDescriptionLabel)
        CSVDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(CSVTitleLabel.snp.bottom).offset(2)
            make.left.equalTo(CSVImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(25)
        }
        CSVDescriptionLabel.numberOfLines = 0
        CSVDescriptionLabel.textColor = .unpauseLightGray
        CSVDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        CSVDescriptionLabel.text = "Let‘s you create CSV file and export it from app. Your friends and team members can get your shifts and open it like sheet."
    }
    
    func renderSendEmailImageView() {
        containerView.addSubview(sendEmailImageView)
        sendEmailImageView.snp.makeConstraints { make in
            make.top.equalTo(CSVDescriptionLabel.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(25)
            make.height.width.equalTo(80)
        }
        sendEmailImageView.image = UIImage(named: "sendEmail_80x80")
        sendEmailImageView.contentMode = .scaleAspectFit
    }
    
    func renderSendEmailTitleLabel() {
        containerView.addSubview(sendEmailTitleLabel)
        sendEmailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(CSVDescriptionLabel.snp.bottom).offset(30)
            make.left.equalTo(sendEmailImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(25)
        }
        sendEmailTitleLabel.text = "Send email"
        sendEmailTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        sendEmailTitleLabel.numberOfLines = 0
    }
    
    func renderSendEmailDescriptionLabel() {
        containerView.addSubview(sendEmailDescriptionLabel)
        sendEmailDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(sendEmailTitleLabel.snp.bottom).offset(2)
            make.left.equalTo(sendEmailImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(25)
        }
        sendEmailDescriptionLabel.numberOfLines = 0
        sendEmailDescriptionLabel.textColor = .unpauseLightGray
        sendEmailDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        sendEmailDescriptionLabel.text = "Send your shifts as sheet document to your boss or your team members. Everything is set up and you just need one click."
    }
    
    func renderOneMonthSubscriptionLabel() {
        containerView.addSubview(oneMonthSubscriptionLabel)
        oneMonthSubscriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(sendEmailDescriptionLabel.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        oneMonthSubscriptionLabel.text = "One month subscription"
        oneMonthSubscriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        oneMonthSubscriptionLabel.numberOfLines = 0
        oneMonthSubscriptionLabel.textColor = .unpauseGreen
    }
    
    func renderOneMontSubscriptionButton() {
        containerView.addSubview(oneMonthSubscriptionButton)
        oneMonthSubscriptionButton.snp.makeConstraints { make in
            make.top.equalTo(oneMonthSubscriptionLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
        oneMonthSubscriptionButton.setTitle("Buy for $0.99", for: .normal)
        oneMonthSubscriptionButton.backgroundColor = .unpauseGreen
        oneMonthSubscriptionButton.layer.cornerRadius = 20
    }
    
    func renderOneYearSubscriptionLabel() {
        containerView.addSubview(oneYearSubscriptionLabel)
        oneYearSubscriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(oneMonthSubscriptionButton.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        oneYearSubscriptionLabel.text = "One year subscription"
        oneYearSubscriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        oneYearSubscriptionLabel.numberOfLines = 0
        oneYearSubscriptionLabel.textColor = .unpauseGreen
    }
    
    func renderOneYearSubscriptionButton() {
        containerView.addSubview(oneYearSubscriptionButton)
        oneYearSubscriptionButton.snp.makeConstraints { make in
            make.top.equalTo(oneYearSubscriptionLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().inset(15)
            make.height.equalTo(50)
        }
        oneYearSubscriptionButton.setTitle("Buy for $6.99", for: .normal)
        oneYearSubscriptionButton.backgroundColor = .unpauseGreen
        oneYearSubscriptionButton.layer.cornerRadius = 20
    }
}

// MARK: - SKPaymentTransactionObserver
extension UpgradeToProViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                SKPaymentQueue.default().finishTransaction(transaction)
                self.dismiss(animated: true)
            } else if transaction.transactionState == .failed {
                guard let error = transaction.error else { return }
                UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                self.showOneOptionAlert(title: "The purchase was not successful", message: "\(error.localizedDescription)", actionTitle: "OK")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
