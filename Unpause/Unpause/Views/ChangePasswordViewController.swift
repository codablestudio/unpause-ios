//
//  ChangePasswordViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class ChangePasswordViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let changePasswordViewModel: ChangePasswordViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let changePasswordLabel = UILabel()
    private let changePasswordSeparator = UIView()
    
    private let currentPasswordTextField = UITextField()
    private let currentPasswordSeparator = UIView()
    
    private let newPasswordTextField = UITextField()
    private let newPasswordSeparator = UIView()
    
    private let changePasswordButton = OrangeButton(title: "Change password", height: 35)
    
    private let closeButton = UIButton()
    
    init(changePasswordViewModel: ChangePasswordViewModel) {
        self.changePasswordViewModel = changePasswordViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        setUpTextFields()
        addGestureRecognizer()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderChangePasswordLabelAndSeparator()
        renderCurrentPasswordAndCurrentPasswordSeparator()
        renderNewPasswordAndNewPasswordSeparator()
        renderChangePasswordButton()
        renderCloseButton()
    }
    
    private func setUpObservables() {
        currentPasswordTextField.rx.text
            .bind(to: changePasswordViewModel.textInCurrentPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        newPasswordTextField.rx.text
            .bind(to: changePasswordViewModel.textInNewPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        changePasswordButton.rx.tap
            .do(onNext: { _ in
                SVProgressHUD.show()
            })
            .bind(to: changePasswordViewModel.changePasswordButtonTapped)
            .disposed(by: disposeBag)

        changePasswordViewModel.changePasswordResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    SVProgressHUD.showSuccess(withStatus: "Password updated successfully")
                    SVProgressHUD.dismiss(withDelay: 0.6)
                    self.dismiss(animated: true)
                case .error(let error):
                    if let error = error as? UnpauseError, error == UnpauseError.emptyError {
                        self.showAlert(title: "Error", message: "Please fill empty fields.", actionTitle: "OK")
                    } else {
                        self.showAlert(title: "Error", message: error.localizedDescription, actionTitle: "OK")
                    }
                    SVProgressHUD.dismiss()
                }
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func setUpTextFields() {
        currentPasswordTextField.setNextResponder(newPasswordTextField, disposeBag: disposeBag)
        newPasswordTextField.resignWhenFinished(disposeBag)
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] (tapGesture) in
            self?.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
}

// MARK: - UI rendering
private extension ChangePasswordViewController {
    
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
    
    func renderChangePasswordLabelAndSeparator() {
        containerView.addSubview(changePasswordLabel)
        changePasswordLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        changePasswordLabel.text = "Change password"
        changePasswordLabel.textColor = UIColor.orange
        changePasswordLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        containerView.addSubview(changePasswordSeparator)
        changePasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(changePasswordLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        changePasswordSeparator.backgroundColor = UIColor.orange
    }
    
    func renderCurrentPasswordAndCurrentPasswordSeparator() {
        containerView.addSubview(currentPasswordTextField)
        currentPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(changePasswordSeparator.snp.bottom).offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        currentPasswordTextField.placeholder = "Enter current password"
        currentPasswordTextField.autocorrectionType = .no
        currentPasswordTextField.autocapitalizationType = .none
        currentPasswordTextField.isSecureTextEntry = true
        
        containerView.addSubview(currentPasswordSeparator)
        currentPasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(currentPasswordTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        currentPasswordSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderNewPasswordAndNewPasswordSeparator() {
        containerView.addSubview(newPasswordTextField)
        newPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(currentPasswordSeparator.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        newPasswordTextField.placeholder = "Enter new password"
        newPasswordTextField.autocorrectionType = .no
        newPasswordTextField.autocapitalizationType = .none
        newPasswordTextField.isSecureTextEntry = true
        
        containerView.addSubview(newPasswordSeparator)
        newPasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        newPasswordSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderChangePasswordButton() {
        containerView.addSubview(changePasswordButton)
        changePasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.bottom.equalToSuperview()
        }
    }
    
    func renderCloseButton() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.left.equalToSuperview().offset(15)
        }
        closeButton.setImage(UIImage(named: "close_25x25"), for: .normal)
    }
}
