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
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let loginViewModel: LoginViewModelProtocol
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let scrollViewContainer = UIView()
    
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
    
    var googleUserSignInResponse = PublishSubject<GIDGoogleUser>()
    
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
        setUpGoogleDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderEmailTextFieldAndEmailSeparator()
        renderPasswordTextFieldAndPasswordSeparator()
        renderForgotPasswordButtonAndLoginButton()
        renderSignInWithGoogleButtonAndNewHereLabel()
        renderRegisterButton()
    }
    
    private func setupObservables() {
        emailTextField.rx.text
            .bind(to: loginViewModel.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .bind(to: loginViewModel.textInPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        forgotPasswordButton.rx.tap.subscribe(onNext: { _ in
            Coordinator.shared.presentForgotPasswordViewController(from: self)
        }).disposed(by: disposeBag)
        
        signInWithGoogleButton.rx.tap
            .subscribe(onNext: { _ in
                GIDSignIn.sharedInstance()?.presentingViewController = self
                GIDSignIn.sharedInstance().signIn()
            }).disposed(by: disposeBag)
        
        loginButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: loginViewModel.logInButtonTapped)
            .disposed(by: disposeBag)
        
        loginViewModel.loginDocument
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    Coordinator.shared.navigateToHomeViewController()
                case .error(let error):
                    switch error {
                    case .noCompany:
                        UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                        Coordinator.shared.navigateToHomeViewController()
                    default:
                        UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                        self.showOneOptionAlert(title: "Error", message: "\(error.errorMessage)", actionTitle: "OK")
                    }
                }
            }).disposed(by: disposeBag)
        
        googleUserSignInResponse
            .bind(to: loginViewModel.googleUserSignInResponse)
            .disposed(by: disposeBag)
        
        loginViewModel.isInsideGoogleSignInFlow
            .bind(to: signInWithGoogleButton.rx.animating)
            .disposed(by: disposeBag)
        
        loginViewModel.googleUserSavingResponse
            .subscribe(onNext: { unpauseResponse in
                switch unpauseResponse {
                case .success:
                    Coordinator.shared.navigateToHomeViewController()
                    self.dismiss(animated: true)
                case .error(let error):
                    if error == UnpauseError.noCompany {
                        Coordinator.shared.navigateToHomeViewController()
                        self.dismiss(animated: true)
                    } else {
                        self.showOneOptionAlert(title: "Alert", message: "\(error.errorMessage)", actionTitle: "OK")
                    }
                }
            }).disposed(by: disposeBag)
        
        
        registerButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            Coordinator.shared.presentRegistrationViewController(from: self)
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
    
    private func setUpGoogleDelegate() {
        GIDSignIn.sharedInstance().delegate = self
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: - UI rendering
private extension LoginViewController {
    
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        renderLogo()
        
        containerView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleDesriptionLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
        }
    }
    
    func renderLogo() {
        containerView.addSubview(titleStackView)
        titleStackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.height / 8)
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
        unpauseTitleLabel.textColor = UIColor.unpauseOrange
        
        containerView.addSubview(titleDesriptionLabel)
        titleDesriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleStackView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        titleDesriptionLabel.text = "Enjoy managing your working time"
        titleDesriptionLabel.font = titleDesriptionLabel.font.withSize(13)
        titleDesriptionLabel.textColor = UIColor.unpauseDarkGray
    }
    
    func renderEmailTextFieldAndEmailSeparator() {
        scrollViewContainer.addSubview(emailTextField)
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
        emailTextField.textContentType = .emailAddress
        
        scrollViewContainer.addSubview(emailSeparator)
        emailSeparator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
        }
        emailSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderPasswordTextFieldAndPasswordSeparator() {
        scrollViewContainer.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(65)
            make.right.equalToSuperview().inset(65)
        }
        passwordTextField.placeholder = "Enter password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .done
        passwordTextField.textContentType = .password
        
        scrollViewContainer.addSubview(passwordSeparator)
        passwordSeparator.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.top.equalTo(passwordTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
        }
        passwordSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderForgotPasswordButtonAndLoginButton() {
        scrollViewContainer.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.top.equalTo(passwordSeparator.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(62)
        }
        forgotPasswordButton.setTitle("Forgot password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = forgotPasswordButton.titleLabel?.font.withSize(13)
        forgotPasswordButton.setTitleColor(UIColor.unpauseOrange, for: .normal)
        
        scrollViewContainer.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(55)
            make.right.equalToSuperview().inset(55)
            make.height.equalTo(50)
        }
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.unpauseOrange
        loginButton.layer.cornerRadius = 25
    }
    
    func renderSignInWithGoogleButtonAndNewHereLabel() {
        scrollViewContainer.addSubview(signInWithGoogleButton)
        signInWithGoogleButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(85)
            make.right.equalToSuperview().inset(85)
            make.centerX.equalToSuperview()
        }
        signInWithGoogleButton.setTitle("Sign in with Google", for: .normal)
        signInWithGoogleButton.titleLabel?.font = signInWithGoogleButton.titleLabel?.font.withSize(15)
        signInWithGoogleButton.backgroundColor = UIColor.unpauseOrange
        signInWithGoogleButton.layer.cornerRadius = 15
        signInWithGoogleButton.titleEdgeInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7)
        
        scrollViewContainer.addSubview(newHereLabel)
        newHereLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signInWithGoogleButton.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
        newHereLabel.text = "New here?"
        newHereLabel.font = newHereLabel.font.withSize(14)
        newHereLabel.textColor = UIColor.unpauseDarkGray
    }
    
    func renderRegisterButton() {
        scrollViewContainer.addSubview(registerButton)
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(newHereLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        let underlinedText = NSAttributedString(string: "Register now",
                                                attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                             NSAttributedString.Key.foregroundColor : UIColor.unpauseOrange])
        registerButton.setAttributedTitle(underlinedText, for: .normal)
    }
}

// MARK: - GIDSignIn delegate
extension LoginViewController: GIDSignInDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("ERROR: \(error.localizedDescription)")
        } else {
            if let user = user {
                googleUserSignInResponse.onNext(user)
            }
        }
    }
}
