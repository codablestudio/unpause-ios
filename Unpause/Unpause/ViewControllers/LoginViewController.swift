//
//  LoginViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 11/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class LoginViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let loginViewModel: LoginViewModel
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let titleStackView = UIStackView()
    private let welcomeToTitleLabel = UILabel()
    private let unpauseTitleLabel = UILabel()
    private let titleDesriptionLabel = UILabel()
    
    private let emailTextField = UITextField()
    private let emailSeparator = UIView()
    private let passwordTextField = UITextField()
    private let passwordSeparator = UIView()
    private let forgotPasswordButton = UIButton()
    private let signInWithGoogleButton = UIButton()
    
    private let loginButton = UIButton()
    private let newHereLabel = UILabel()
    private let registerButton = UIButton()
    
    // MARK: - Public properties
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        render()
    }
    
    // MARK: - Initializers
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func hideNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func render() {
        view.backgroundColor = .white
        
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
        
        renderLogo()
        
        containerView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(titleDesriptionLabel.snp.bottom).offset(85)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(65)
        }
        emailTextField.placeholder = "Enter email"
        emailTextField.autocorrectionType = .no
        
        containerView.addSubview(emailSeparator)
        emailSeparator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().inset(60)
            make.bottom.equalToSuperview()
        }
        emailSeparator.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
}

// MARK: - UI rendering

private extension LoginViewController {
    func renderLogo() {
        containerView.addSubview(titleStackView)
        titleStackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(120)
            make.centerX.equalToSuperview()
        }
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 5
        
        titleStackView.addArrangedSubview(welcomeToTitleLabel)
        welcomeToTitleLabel.text = "Welcome to"
        welcomeToTitleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        titleStackView.addArrangedSubview(unpauseTitleLabel)
        unpauseTitleLabel.text = "Unpause"
        unpauseTitleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        unpauseTitleLabel.textColor = #colorLiteral(red: 0.9450980392, green: 0.4745098039, blue: 0.2078431373, alpha: 1)
        
        containerView.addSubview(titleDesriptionLabel)
        titleDesriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleStackView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        titleDesriptionLabel.text = "Enjoy managing your workitime"
        titleDesriptionLabel.font = titleDesriptionLabel.font.withSize(13)
        titleDesriptionLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
}
