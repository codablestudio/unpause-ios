//
//  ChangePasswordViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class ChangePasswordViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let changePasswordViewModel: ChangePasswordViewModelProtocol
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let currentPasswordTextField = UITextField()
    private let currentPasswordSeparator = UIView()
    
    let newPasswordTextField = UITextField()
    private let newPasswordSeparator = UIView()
    
    private let changePasswordButton = OrangeButton(title: "Change password")
    
    init(changePasswordViewModel: ChangePasswordViewModelProtocol) {
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
        setUpViewControllerTitle()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderCurrentPasswordAndCurrentPasswordSeparator()
        renderNewPasswordAndNewPasswordSeparator()
        renderChangePasswordButton()
    }
    
    private func setUpObservables() {
        currentPasswordTextField.rx.text
            .bind(to: changePasswordViewModel.textInCurrentPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        newPasswordTextField.rx.text
            .bind(to: changePasswordViewModel.textInNewPasswordTextFieldChanges)
            .disposed(by: disposeBag)
        
        changePasswordButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dismissKeyboard()
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: changePasswordViewModel.changePasswordButtonTapped)
            .disposed(by: disposeBag)

        changePasswordViewModel.changePasswordResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                    self.navigationController?.popViewController(animated: true)
                case .error(let error):
                    self.showOneOptionAlert(title: "Error", message: "\(error.errorMessage)", actionTitle: "OK")
                    UnpauseActivityIndicatorView.shared.dismiss(from: self.view)
                }
            })
            .disposed(by: disposeBag)
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

    private func setUpViewControllerTitle() {
        self.title = "Change password"
        navigationItem.largeTitleDisplayMode = .never
    }
}

// MARK: - UI rendering
private extension ChangePasswordViewController {
    
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.unpauseWhite
        
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
            make.width.equalToSuperview()
        }
    }
    
    func renderCurrentPasswordAndCurrentPasswordSeparator() {
        containerView.addSubview(currentPasswordTextField)
        currentPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        currentPasswordTextField.placeholder = "Enter current password"
        currentPasswordTextField.autocorrectionType = .no
        currentPasswordTextField.autocapitalizationType = .none
        currentPasswordTextField.isSecureTextEntry = true
        currentPasswordTextField.returnKeyType = .next
        
        containerView.addSubview(currentPasswordSeparator)
        currentPasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(currentPasswordTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        currentPasswordSeparator.backgroundColor = UIColor.unpauseLightGray
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
        newPasswordTextField.returnKeyType = .done
        
        containerView.addSubview(newPasswordSeparator)
        newPasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        newPasswordSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderChangePasswordButton() {
        containerView.addSubview(changePasswordButton)
        changePasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        changePasswordButton.layer.cornerRadius = 25
    }
}
