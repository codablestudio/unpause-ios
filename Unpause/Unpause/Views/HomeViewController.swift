//
//  HomeViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let homeViewModel: HomeViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let signedInLabel = UILabel()
    
    private let emailLabel = UILabel()
    private let userEmailLabel = UILabel()
    
    private let firstNameLabel = UILabel()
    private let userFirstNameLabel = UILabel()
    
    private let lastNameLabel = UILabel()
    private let userLastNameLabel = UILabel()
    
    private let checkInButton = UIButton()
    
    
    init(homeViewModel: HomeViewModel) {
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
    
    private func render() {
        configureScrollViewAndContainerView()
        renderSignedInLabel()
        renderEmailLabelAndUserEmailLabel()
        renderFirstNameLabelAndUserFirstNameLabel()
        renderLastNameLabelAndUserLastNameLabel()
        renderCheckInButton()
    }
    
    private func setUpObservables() {
        checkInButton.rx.tap.bind(to: homeViewModel.checkInButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func showTitleInNavigationBar() {
        self.title = "Home"
    }
}

// MARK: - UI rendering

private extension HomeViewController {
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor(named: "white")
        
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
            make.topMargin.equalToSuperview().offset(135)
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
        emailLabel.textColor = UIColor(named: "lightGray")
        
        containerView.addSubview(userEmailLabel)
        userEmailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signedInLabel.snp.bottom).offset(20)
            make.left.equalTo(emailLabel.snp.right).offset(7)
            make.right.equalToSuperview()
        }
        userEmailLabel.text = SessionManager.shared.currentUser?.email ?? "No user"
        userEmailLabel.textColor = UIColor(named: "lightGray")
    }
    
    func renderFirstNameLabelAndUserFirstNameLabel() {
        containerView.addSubview(firstNameLabel)
        firstNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emailLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
        }
        firstNameLabel.text = "First name:"
        firstNameLabel.textColor = UIColor(named: "lightGray")
        
        containerView.addSubview(userFirstNameLabel)
        userFirstNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(emailLabel.snp.bottom).offset(20)
            make.left.equalTo(firstNameLabel.snp.right).offset(7)
            make.right.equalToSuperview()
        }
        // TODO: Fill up this field with users data
        userFirstNameLabel.text = "Kresimir"
        userFirstNameLabel.textColor = UIColor(named: "lightGray")
    }
    
    func renderLastNameLabelAndUserLastNameLabel() {
        containerView.addSubview(lastNameLabel)
        lastNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
        }
        lastNameLabel.text = "Last name:"
        lastNameLabel.textColor = UIColor(named: "lightGray")
        
        containerView.addSubview(userLastNameLabel)
        userLastNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameLabel.snp.bottom).offset(20)
            make.left.equalTo(lastNameLabel.snp.right).offset(7)
            make.right.equalToSuperview()
        }
        // TODO: Fill up this field with users data
        userLastNameLabel.text = "Bakovic"
        userLastNameLabel.textColor = UIColor(named: "lightGray")
    }
    
    func renderCheckInButton() {
        containerView.addSubview(checkInButton)
        checkInButton.snp.makeConstraints { (make) in
            make.top.equalTo(lastNameLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(140)
            make.width.equalTo(140)
            make.bottom.equalToSuperview()
        }
        checkInButton.backgroundColor = UIColor(named: "orange")
        checkInButton.layer.cornerRadius = 70
        checkInButton.setTitle("Check in", for: .normal)
        checkInButton.titleLabel?.font = checkInButton.titleLabel?.font.withSize(25)
    }
}
