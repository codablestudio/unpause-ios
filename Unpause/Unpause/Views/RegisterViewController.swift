//
//  RegisterViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxKeyboard
import SVProgressHUD
import RxGesture

class RegisterViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let registerViewModel: RegisterViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let registrationLabel = UILabel()
    
    private let firstNameTextField = UITextField()
    private let firstNameSeparator = UIView()
    
    private let lastNameTextField = UITextField()
    private let lastNameSeparator = UIView()
    
    private let emailTextField = UITextField()
    private let emailSeparator = UIView()
    
    private let newPasswordTextField = UITextField()
    private let newPasswordSeparator = UIView()
    
    private let registerButton = UIButton()
    
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
        setUpKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderRegistrationLabel()
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
        
        registerButton.rx.tap.bind(to: registerViewModel.registerButtonTapped)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap.subscribe(onNext: { _ in
            SVProgressHUD.show()
            }).disposed(by: disposeBag)
        
        registerViewModel.registerResponse.subscribe(onNext: { [weak self] (firebaseResponseObject) in
            switch firebaseResponseObject {
            case .authDataResult(let authDataResult):
                print("\(authDataResult.user.email!)")
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "Success")
                SVProgressHUD.dismiss(withDelay: 0.3)
                self?.dismiss(animated: true, completion: nil)
            case .error(let error):
                SVProgressHUD.dismiss()
                self?.showAlert(title: "Error", message: "\(error.localizedDescription)", actionTitle: "OK")
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
    
    private func setUpKeyboard() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] (keyboardVisibleHeight) in
            self?.registerButton.snp.remakeConstraints { (make) in
                make.top.equalTo((self?.newPasswordSeparator)!).offset(30)
                make.left.equalToSuperview().offset(42)
                make.right.equalToSuperview().inset(42)
                make.bottom.equalToSuperview().inset(keyboardVisibleHeight)
                make.height.equalTo(40)
            }
        }).disposed(by: disposeBag)
    }
    
    private func showAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: - UI rendering

private extension RegisterViewController {
    
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
    
    func renderRegistrationLabel() {
        containerView.addSubview(registrationLabel)
        registrationLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(160)
            make.left.equalToSuperview().offset(50)
        }
        registrationLabel.text = "Registration"
        registrationLabel.font = UIFont.boldSystemFont(ofSize: 30)
    }
    
    func renderFirstNameTextFieldAndFirstNameSeparator() {
        containerView.addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(registrationLabel.snp.bottom).offset(40)
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
        firstNameSeparator.backgroundColor = UIColor(named: "lightGray")
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
        lastNameSeparator.backgroundColor = UIColor(named: "lightGray")
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
        emailSeparator.backgroundColor = UIColor(named: "lightGray")
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
        newPasswordSeparator.backgroundColor = UIColor(named: "lightGray")
    }
    
    func renderRegisterButton() {
        containerView.addSubview(registerButton)
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordSeparator).offset(30)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = UIColor(named: "orange")
        registerButton.layer.cornerRadius = 5
    }
    
    func renderCloseButton() {
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(15)
        }
        closeButton.setImage(UIImage(named: "close_25x25"), for: .normal)
    }
}
