//
//  UpgradeToProViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class UpgradeToProViewController: UIViewController {
    
    private let upgradeToProViewModel: UpgradeToProViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let premiumFeaturesView = UIView()
    private let premiumFeaturesImageView = UIImageView()
    private let premiumFeaturesTitleLabel = UILabel()
    private let premiumFeaturesDescriptionLabel = UILabel()
    
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
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderPremiumFeaturesViewAndItsSubviews()
    }
    
    private func setUpObservables() {
        
    }
    
    private func setUpViewControllerTitle() {
        self.title = "Pro version"
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
            make.width.equalTo(UIScreen.main.bounds.width)
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
}
