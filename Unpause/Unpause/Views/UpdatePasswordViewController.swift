//
//  UpdatePasswordViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class UpdatePasswordViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let updatePasswordViewModel: UpdatePasswordViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let currentPasswordTextField = UITextField()
    private let currentPasswordSeparator = UIView()
    
    private let newPasswordTextField = UITextField()
    private let newPasswordSeparator = UIView()
    
    private let updatePasswordButton = OrangeButton(title: "Update password")
    
    private let closeButton = UIButton()
    
    init(updatePasswordViewModel: UpdatePasswordViewModel) {
        self.updatePasswordViewModel = updatePasswordViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderCurrentPasswordAndCurrentPasswordSeparator()
        renderNewPasswordAndNewPasswordSeparator()
        renderUpdatePasswordButton()
        renderCloseButton()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
}

// MARK: - UI rendering

private extension UpdatePasswordViewController {
    
    func configureScrollViewAndContainerView() {
        view.backgroundColor = UIColor.white
        
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
    
    func renderCurrentPasswordAndCurrentPasswordSeparator() {
        containerView.addSubview(currentPasswordTextField)
        currentPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(260)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().inset(35)
        }
        currentPasswordTextField.placeholder = "Enter current password"
        currentPasswordTextField.autocorrectionType = .no
        currentPasswordTextField.autocapitalizationType = .none
        
        containerView.addSubview(currentPasswordSeparator)
        currentPasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(currentPasswordTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(1)
        }
        currentPasswordSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderNewPasswordAndNewPasswordSeparator() {
        containerView.addSubview(newPasswordTextField)
        newPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(currentPasswordSeparator.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().inset(35)
        }
        newPasswordTextField.placeholder = "Enter new password"
        newPasswordTextField.autocorrectionType = .no
        newPasswordTextField.autocapitalizationType = .none
        
        containerView.addSubview(newPasswordSeparator)
        newPasswordSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(1)
        }
        newPasswordSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderUpdatePasswordButton() {
        containerView.addSubview(updatePasswordButton)
        updatePasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordSeparator.snp.bottom).offset(70)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.bottom.equalToSuperview()
        }
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
