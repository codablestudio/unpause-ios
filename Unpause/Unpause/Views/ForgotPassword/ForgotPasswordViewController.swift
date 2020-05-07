//
//  ForgotPasswordViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class ForgotPasswordViewController: UIViewController {
    
    private let forgotPasswordViewModel: ForgotPasswordViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let emailTextField = UITextField()
    private let emailSeparator = UIView()
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
    private let sendRecoveryEmailButton = OrangeButton(title: "Send recovery email")
    
    init(forgotPasswordViewModel: ForgotPasswordViewModelProtocol) {
        self.forgotPasswordViewModel = forgotPasswordViewModel
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
        addBarButtonItem()
        setUpViewControllerTitle()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderEmailTextFieldAndEmailSeparator()
        renderSendRecoveryEmailButton()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        emailTextField.rx.text
            .bind(to: forgotPasswordViewModel.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        sendRecoveryEmailButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dismissKeyboard()
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: forgotPasswordViewModel.sendRecoveryEmailButtonTapped)
            .disposed(by: disposeBag)
        
        forgotPasswordViewModel.recoveryMailSendingResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    self.dismiss(animated: true)
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    self.showOneOptionAlert(title: "Alert", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func addBarButtonItem() {
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setUpViewControllerTitle() {
        self.title = "Password reset"
    }
}

// MARK: - UI rendering
private extension ForgotPasswordViewController {
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
            make.width.equalTo(UIScreen.main.bounds.width)
        }
    }
    
    func renderEmailTextFieldAndEmailSeparator() {
        containerView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        emailTextField.placeholder = "Enter email"
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .done
        
        containerView.addSubview(emailSeparator)
        emailSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        emailSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderSendRecoveryEmailButton() {
        containerView.addSubview(sendRecoveryEmailButton)
        sendRecoveryEmailButton.snp.makeConstraints { (make) in
            make.top.equalTo(emailSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        sendRecoveryEmailButton.layer.cornerRadius = 25
    }
}
