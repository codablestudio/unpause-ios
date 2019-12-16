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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderRegistrationLabel()
    }
}

private extension RegisterViewController {
    
    func configureScrollViewAndContainerView() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        
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
        
        containerView.addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(registrationLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        firstNameTextField.placeholder = "Enter first name"
        
        containerView.addSubview(firstNameSeparator)
        firstNameSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        firstNameSeparator.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
    }
}
