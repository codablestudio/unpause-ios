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
    private let registerViewModel: RegisterViewModelProtocol
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let firstNameTextField = UITextField()
    private let firstNameSeparator = UIView()
    
    private let lastNameTextField = UITextField()
    private let lastNameSeparator = UIView()
    
    private let emailTextField = UITextField()
    private let emailSeparator = UIView()
    
    private let newPasswordTextField = UITextField()
    private let newPasswordSeparator = UIView()
    
    private let registerButton = OrangeButton(title: "Register")
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
    init(registerViewModel: RegisterViewModelProtocol) {
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
        setUpKeyboard()
        addBarButtonItem()
        setUpViewControllerTitle()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderFirstNameTextFieldAndFirstNameSeparator()
        renderLastNameTextFieldAndLastNameSeparator()
        renderEmailTextFieldAndEmailSeparator()
        renderNewPasswordTextFieldAndPasswordSeparator()
        renderRegisterButton()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
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
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: registerViewModel.registerButtonTapped)
            .disposed(by: disposeBag)
        
        registerViewModel.registerResponse
            .subscribe(onNext: { [weak self] firebaseResponseObject in
                guard let `self` = self else { return }
                switch firebaseResponseObject {
                case .success(let authDataResult):
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    Coordinator.shared.navigateToAddCompanyViewController(from: self, registeredUserEmail: authDataResult.user.email)
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    self.showOneOptionAlert(title: "Error", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
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
    
    private func setUpKeyboard() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyboardVisibleHeight in
            guard let `self` = self else { return }
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardVisibleHeight, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }).disposed(by: disposeBag)
    }
    
    private func addBarButtonItem() {
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setUpViewControllerTitle() {
        self.title = "Registration"
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
    
    func renderFirstNameTextFieldAndFirstNameSeparator() {
        containerView.addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        firstNameTextField.placeholder = "Enter first name(optional)"
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
        lastNameTextField.placeholder = "Enter last name(optional)"
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
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .emailAddress
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
        newPasswordTextField.isSecureTextEntry = true
        if #available(iOS 12.0, *) {
            newPasswordTextField.textContentType = .newPassword
        }
        
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
}
