//
//  RegisterViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import RxKeyboard
import RxGesture

class RegisterViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let registerViewModel: RegisterViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let registrationLabel = UILabel()
    private let registrationSeparator = UIView()
    
    private let firstNameTextField = UITextField()
    private let firstNameSeparator = UIView()
    
    private let lastNameTextField = UITextField()
    private let lastNameSeparator = UIView()
    
    private let emailTextField = UITextField()
    private let emailSeparator = UIView()
    
    private let newPasswordTextField = UITextField()
    private let newPasswordSeparator = UIView()
    
    private let registerButton = OrangeButton(title: "Register")
    
    private let closeButton = UIButton()
    
    init(registerViewModel: RegisterViewModel) {
        self.registerViewModel = registerViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        addGestureRecognizer()
        setUpTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderRegistrationLabelAndRegistrationSeparator()
        renderFirstNameTextFieldAndFirstNameSeparator()
        renderLastNameTextFieldAndLastNameSeparator()
        renderEmailTextFieldAndEmailSeparator()
        renderNewPasswordTextFieldAndPasswordSeparator()
        renderRegisterButton()
        renderCloseButton()
    }
    
    private func setUpObservables() {
        firstNameTextField.rx.text.bind(to: registerViewModel.textInFirstNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        lastNameTextField.rx.text.bind(to: registerViewModel.textInLastNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.bind(to: registerViewModel.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        newPasswordTextField.rx.text.bind(to: registerViewModel.textInNewPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                ActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: registerViewModel.registerButtonTapped)
            .disposed(by: disposeBag)
        
        registerViewModel.registerResponse
            .subscribe(onNext: { [weak self] firebaseResponseObject in
                guard let `self` = self else { return }
                switch firebaseResponseObject {
                case .success(let authDataResult):
                    print("\(authDataResult.user.email!)")
                    ActivityIndicatorView.shared.dissmis()
                    Coordinator.shared.navigateToAddCompanyViewController(from: self, registeredUserEmail: authDataResult.user.email)
                case .error(let error):
                    ActivityIndicatorView.shared.dissmis()
                    self.showAlert(title: "Error", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] (tapGesture) in
            self?.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func setUpTextFields() {
        firstNameTextField.setNextResponder(lastNameTextField, disposeBag: disposeBag)
        lastNameTextField.setNextResponder(emailTextField, disposeBag: disposeBag)
        emailTextField.setNextResponder(newPasswordTextField, disposeBag: disposeBag)
        newPasswordTextField.resignWhenFinished(disposeBag)
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: - UI rendering
private extension RegisterViewController {
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
    
    func renderRegistrationLabelAndRegistrationSeparator() {
        containerView.addSubview(registrationLabel)
        registrationLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        registrationLabel.text = "Registration"
        registrationLabel.textColor = UIColor.unpauseOrange
        registrationLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        containerView.addSubview(registrationSeparator)
        registrationSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(registrationLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        registrationSeparator.backgroundColor = UIColor.unpauseOrange
    }

    func renderFirstNameTextFieldAndFirstNameSeparator() {
        containerView.addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(registrationSeparator.snp.bottom).offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        firstNameTextField.placeholder = "Enter first name"
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .words
        
        containerView.addSubview(firstNameSeparator)
        firstNameSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        firstNameSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderLastNameTextFieldAndLastNameSeparator() {
        containerView.addSubview(lastNameTextField)
        lastNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameSeparator.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        lastNameTextField.placeholder = "Enter last name"
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .words
        
        containerView.addSubview(lastNameSeparator)
        lastNameSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(lastNameTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        lastNameSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderEmailTextFieldAndEmailSeparator() {
        containerView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(lastNameSeparator.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        emailTextField.placeholder = "Enter email"
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        
        
        containerView.addSubview(emailSeparator)
        emailSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        emailSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderNewPasswordTextFieldAndPasswordSeparator() {
        containerView.addSubview(newPasswordTextField)
        newPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailSeparator.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        newPasswordTextField.placeholder = "Enter new password"
        newPasswordTextField.autocorrectionType = .no
        newPasswordTextField.autocapitalizationType = .none
        newPasswordTextField.isSecureTextEntry = true
        
        containerView.addSubview(newPasswordSeparator)
        newPasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        newPasswordSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderRegisterButton() {
        containerView.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(newPasswordSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
            
        }
        registerButton.layer.cornerRadius = 25
    }
    
    func renderCloseButton() {
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.left.equalToSuperview().offset(15)
        }
        closeButton.setImage(UIImage(named: "close_25x25"), for: .normal)
    }
}
