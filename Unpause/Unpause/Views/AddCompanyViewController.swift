//
//  AddCompanyViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class AddCompanyViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let addCompanyViewModel: AddCompanyViewModel
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let addCompanyLabel = UILabel()
    private let addCompanySeparator = UIView()
    
    private let companyNameTextField = UITextField()
    private let companyNameSeparator = UIView()
    
    private let companyPassCodeTextField = UITextField()
    private let companyPassCodeSeparator = UIView()
    
    private let addCompanyButton = OrangeButton(title: "Add company")
    
    private let closeButton = UIButton()
    
    private let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: nil)
    
    init(addCompanyViewModel: AddCompanyViewModel) {
        self.addCompanyViewModel = addCompanyViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        addBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showNavigationBar()
        hideBackButton()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderAddingCompanyLabelAndAddingCompanySeparator()
        renderCompanyNameTextFieldAndCompanyNameSeparator()
        renderCompanyPasscodeTextFieldAndSeparator()
        renderAddCompanyButton()
        renderCloseButton()
    }
    
    private func setUpObservables() {
        companyNameTextField.rx.text
            .bind(to: addCompanyViewModel.textInCompanyNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        companyPassCodeTextField.rx.text
            .bind(to: addCompanyViewModel.textInCompanyPassCodeTextFieldChanges)
            .disposed(by: disposeBag)
        
        addCompanyButton.rx.tap
            .do(onNext: { _ in
                SVProgressHUD.show()
            })
            .bind(to: addCompanyViewModel.addCompanyButtonTapped)
            .disposed(by: disposeBag)
        
        addCompanyViewModel.companyAddingResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "Company successfully added.")
                    SVProgressHUD.dismiss(withDelay: 0.6)
                    self.dismiss(animated: true)
                case .error(let error):
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Alert", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func addBarButtonItem() {
        navigationItem.rightBarButtonItem = skipButton
        
        skipButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    private func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func hideBackButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}

// MARK: - UI rendering
private extension AddCompanyViewController {
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
    
    func renderAddingCompanyLabelAndAddingCompanySeparator() {
        containerView.addSubview(addCompanyLabel)
        addCompanyLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        addCompanyLabel.text = "Adding company"
        addCompanyLabel.textColor = UIColor.orange
        addCompanyLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        containerView.addSubview(addCompanySeparator)
        addCompanySeparator.snp.makeConstraints { (make) in
            make.top.equalTo(addCompanyLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        addCompanySeparator.backgroundColor = UIColor.orange
    }
    
    func renderCompanyNameTextFieldAndCompanyNameSeparator() {
        containerView.addSubview(companyNameTextField)
        companyNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(addCompanySeparator.snp.bottom).offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        companyNameTextField.placeholder = "Enter company name"
        companyNameTextField.autocorrectionType = .no
        companyNameTextField.autocapitalizationType = .sentences
        
        containerView.addSubview(companyNameSeparator)
        companyNameSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(companyNameTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        companyNameSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderCompanyPasscodeTextFieldAndSeparator() {
        containerView.addSubview(companyPassCodeTextField)
        companyPassCodeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(companyNameSeparator.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        companyPassCodeTextField.placeholder = "Enter company passcode"
        companyPassCodeTextField.autocorrectionType = .no
        companyPassCodeTextField.autocapitalizationType = .none
        
        containerView.addSubview(companyPassCodeSeparator)
        companyPassCodeSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(companyPassCodeTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        companyPassCodeSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderAddCompanyButton() {
        containerView.addSubview(addCompanyButton)
        addCompanyButton.snp.makeConstraints { make in
            make.top.equalTo(companyPassCodeSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
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
