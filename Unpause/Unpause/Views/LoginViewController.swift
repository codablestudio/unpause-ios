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
import RxGesture
import SVProgressHUD

class LoginViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let loginViewModel: LoginViewModelProtocol
    
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
    
    init(loginViewModel: LoginViewModelProtocol) {
        self.loginViewModel = loginViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setupObservables()
        addGestureRecognizer()
        setUpTextFields()
        setUpKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderLogo()
        renderEmailTextFieldAndEmailSeparator()
        renderPasswordTextFieldAndPasswordSeparator()
        renderForgotPasswordButtonAndSignInWithGoogleButton()
        renderLoginButtonAndNewHereLabel()
        renderRegisterButton()
    }
    
    private func setupObservables() {
        emailTextField.rx.text
            .bind(to: loginViewModel.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .bind(to: loginViewModel.textInPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .bind(to: loginViewModel.logInButtonTapped)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap.subscribe(onNext: { _ in
            SVProgressHUD.show()
        }).disposed(by: disposeBag)
        
        registerButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            Coordinator.shared.presentRegistrationViewController(from: self)
        }).disposed(by: disposeBag)
        
        loginViewModel.loginDocument
            .subscribe(onNext: { [weak self] (firebaseDocumentResponseObject) in
                guard let `self` = self else { return }
                switch firebaseDocumentResponseObject {
                case .documentSnapshot( _):
                    Coordinator.shared.navigateToHomeViewController(from: self)
                case .error(let error):
                    self.showAlert(title: "Error", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
                SVProgressHUD.dismiss()
            }).disposed(by: disposeBag)
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func setUpTextFields() {
        emailTextField.setNextResponder(passwordTextField, disposeBag: disposeBag)
        passwordTextField.resignWhenFinished(disposeBag)
    }
    
    private func setUpKeyboard() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] (keyboardVisibleHeight) in
            self?.registerButton.snp.remakeConstraints { (make) in
                make.top.equalTo((self?.newHereLabel.snp.bottom)!).offset(2)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(keyboardVisibleHeight)
                make.height.equalTo(20)
            }
        }).disposed(by: disposeBag)
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func showAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - UI rendering

private extension LoginViewController {
    
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.whiteUnpauseTextAndBackgroundColor
        
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
        unpauseTitleLabel.textColor = UIColor.orange
        
        containerView.addSubview(titleDesriptionLabel)
        titleDesriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleStackView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        titleDesriptionLabel.text = "Enjoy managing your workitime"
        titleDesriptionLabel.font = titleDesriptionLabel.font.withSize(13)
        titleDesriptionLabel.textColor = UIColor.darkGray
    }
    
    func renderEmailTextFieldAndEmailSeparator() {
        containerView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(titleDesriptionLabel.snp.bottom).offset(85)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(65)
        }
        emailTextField.placeholder = "Enter email"
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .next
        emailTextField.keyboardType = .emailAddress
        
        containerView.addSubview(emailSeparator)
        emailSeparator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
        }
        emailSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderPasswordTextFieldAndPasswordSeparator() {
        containerView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(65)
        }
        passwordTextField.placeholder = "Enter password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .go
        
        containerView.addSubview(passwordSeparator)
        passwordSeparator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.equalTo(passwordTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
        }
        passwordSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderForgotPasswordButtonAndSignInWithGoogleButton() {
        containerView.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.top.equalTo(passwordSeparator.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(62)
        }
        forgotPasswordButton.setTitle("Forgot password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = forgotPasswordButton.titleLabel?.font.withSize(13)
        forgotPasswordButton.setTitleColor(UIColor.orange, for: .normal)
        
        containerView.addSubview(signInWithGoogleButton)
        signInWithGoogleButton.snp.makeConstraints { (make) in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(110)
            make.right.equalToSuperview().inset(110)
            make.centerX.equalToSuperview()
        }
        signInWithGoogleButton.setTitle("Sign in with Google", for: .normal)
        signInWithGoogleButton.titleLabel?.font = signInWithGoogleButton.titleLabel?.font.withSize(15)
        signInWithGoogleButton.backgroundColor = UIColor.orange
        signInWithGoogleButton.layer.cornerRadius = 5
        signInWithGoogleButton.titleEdgeInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7)
    }
    
    func renderLoginButtonAndNewHereLabel() {
        containerView.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(signInWithGoogleButton.snp.bottom).offset(75)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
            make.height.equalTo(40)
        }
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.orange
        loginButton.layer.cornerRadius = 5
        
        containerView.addSubview(newHereLabel)
        newHereLabel.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
        newHereLabel.text = "New here?"
        newHereLabel.font = newHereLabel.font.withSize(14)
        newHereLabel.textColor = UIColor.darkGray
    }
    
    func renderRegisterButton() {
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
