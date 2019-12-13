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
import RxKeyboard

class LoginViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
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
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        render()
        setupObservables()
    }
    
    private func setupObservables() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [scrollView] keyboardVisibleHeight in
                scrollView.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
        
        scrollView.keyboardDismissMode = .onDrag
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .go
        
        
    }
        
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
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
        }
        emailSeparator.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        containerView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(65)
        }
        passwordTextField.placeholder = "Enter password"
        passwordTextField.autocorrectionType = .no
        
        containerView.addSubview(passwordSeparator)
        passwordSeparator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.equalTo(passwordTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
        }
        passwordSeparator.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        containerView.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.top.equalTo(passwordSeparator.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(62)
        }
        forgotPasswordButton.setTitle("Forgot password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = forgotPasswordButton.titleLabel?.font.withSize(13)
        forgotPasswordButton.setTitleColor(#colorLiteral(red: 0.9450980392, green: 0.4745098039, blue: 0.2078431373, alpha: 1), for: .normal)
        
        containerView.addSubview(signInWithGoogleButton)
        signInWithGoogleButton.snp.makeConstraints { (make) in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(110)
            make.right.equalToSuperview().inset(110)
            make.centerX.equalToSuperview()
        }
        signInWithGoogleButton.setTitle("Sign in with Google", for: .normal)
        signInWithGoogleButton.titleLabel?.font = signInWithGoogleButton.titleLabel?.font.withSize(15)
        signInWithGoogleButton.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.4745098039, blue: 0.2078431373, alpha: 1)
        signInWithGoogleButton.layer.cornerRadius = 5
        signInWithGoogleButton.titleEdgeInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7)
        
        containerView.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(signInWithGoogleButton.snp.bottom).offset(75)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
            make.height.equalTo(40)
        }
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.4745098039, blue: 0.2078431373, alpha: 1)
        loginButton.layer.cornerRadius = 5
        
        containerView.addSubview(newHereLabel)
        newHereLabel.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
        newHereLabel.text = "New here?"
        newHereLabel.font = newHereLabel.font.withSize(14)
        newHereLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        containerView.addSubview(registerButton)
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(newHereLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        let underlinedText = NSAttributedString(string: "Register now", attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor : UIColor.orange])
        registerButton.setAttributedTitle(underlinedText, for: .normal)
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
