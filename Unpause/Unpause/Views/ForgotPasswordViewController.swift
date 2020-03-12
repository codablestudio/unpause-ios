//
//  ForgotPasswordViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class ForgotPasswordViewController: UIViewController {
    
    private let forgotPasswordViewModel: ForgotPasswordViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let passwordRecoveryLabel = UILabel()
    private let passwordRecoverySeparator = UIView()
    
    private let emailTextField = UITextField()
    private let emailSeparator = UIView()
    
    private let closeButton = UIButton()
    
    private let sendRecoveryEmailButton = OrangeButton(title: "Send recovery email", height: 35)

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }
    
    init(forgotPasswordViewModel: ForgotPasswordViewModel) {
        self.forgotPasswordViewModel = forgotPasswordViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderPasswordRecoveryLabelAndSeparator()
        renderEmailTextFieldAndEmailSeparator()
        renderSendRecoveryEmailButton()
        renderCloseButton()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        emailTextField.rx.text
            .bind(to: forgotPasswordViewModel.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        sendRecoveryEmailButton.rx.tap
            .do(onNext: { _ in
                SVProgressHUD.show()
            })
            .bind(to: forgotPasswordViewModel.sendRecoveryEmailButtonTapped)
            .disposed(by: disposeBag)
        
        forgotPasswordViewModel.recoveryMailSendingResponse
            .subscribe(onNext: { response in
                switch response {
                case .success:
                    self.dismiss(animated: true)
                    SVProgressHUD.showSuccess(withStatus: "Email sent successfully")
                    SVProgressHUD.dismiss(withDelay: 0.6)
                case .error(let error):
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Alert", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: - UI rendering
private extension ForgotPasswordViewController {
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
    
    func renderPasswordRecoveryLabelAndSeparator() {
        containerView.addSubview(passwordRecoveryLabel)
        passwordRecoveryLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        passwordRecoveryLabel.text = "Password recovery"
        passwordRecoveryLabel.textColor = UIColor.orange
        passwordRecoveryLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        containerView.addSubview(passwordRecoverySeparator)
        passwordRecoverySeparator.snp.makeConstraints { (make) in
            make.top.equalTo(passwordRecoveryLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        passwordRecoverySeparator.backgroundColor = UIColor.orange
    }

    func renderEmailTextFieldAndEmailSeparator() {
        containerView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordRecoverySeparator.snp.bottom).offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        emailTextField.placeholder = "Enter email"
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        
        containerView.addSubview(emailSeparator)
        emailSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        emailSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderSendRecoveryEmailButton() {
        containerView.addSubview(sendRecoveryEmailButton)
        sendRecoveryEmailButton.snp.makeConstraints { (make) in
            make.top.equalTo(emailSeparator.snp.bottom).offset(50)
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
