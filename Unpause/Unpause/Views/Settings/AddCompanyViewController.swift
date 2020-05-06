//
//  AddCompanyViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import MessageUI

class AddCompanyViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let addCompanyViewModel: AddCompanyViewModelProtocol
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let descriptionButton = UIButton()
    
    private let companyNameTextField = UITextField()
    private let companyNameSeparator = UIView()
    
    private let companyPassCodeTextField = UITextField()
    private let companyPassCodeSeparator = UIView()
    
    private let addCompanyButton = OrangeButton(title: "Connect company")
    
    private let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: nil)
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
    var navigationFromRegisterViewController: Bool
    
    init(addCompanyViewModel: AddCompanyViewModelProtocol, navigationFromRegisterViewController: Bool) {
        self.addCompanyViewModel = addCompanyViewModel
        self.navigationFromRegisterViewController = navigationFromRegisterViewController
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
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showTitleInNavigationBar()
        hideBackButton()
        configureBackbuttonVisibility()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderCompanyPasscodeTextFieldAndSeparator()
        renderAddCompanyButton()
        renderDescriptionLabel()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        skipButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true) {
                Coordinator.shared.navigateToHomeViewController()
            }
        }).disposed(by: disposeBag)
        
        companyNameTextField.rx.text
            .bind(to: addCompanyViewModel.textInCompanyNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        companyPassCodeTextField.rx.text
            .bind(to: addCompanyViewModel.textInCompanyPassCodeTextFieldChanges)
            .disposed(by: disposeBag)
        
        addCompanyButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dismissKeyboard()
                UnpauseActivityIndicatorView.shared.show(on: self.view)
            })
            .bind(to: addCompanyViewModel.addCompanyButtonTapped)
            .disposed(by: disposeBag)
        
        addCompanyViewModel.companyAddingResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    self.dismiss(animated: true) {
                        if self.navigationFromRegisterViewController {
                            Coordinator.shared.navigateToHomeViewController()
                        }
                    }
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    self.showOneOptionAlert(title: "Alert", message: "\(error.errorMessage)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        descriptionButton.rx.tap.subscribe(onNext: { _ in
            if MFMailComposeViewController.canSendMail() {
                let mailViewController = MFMailComposeViewController()
                mailViewController.mailComposeDelegate = self
                mailViewController.setToRecipients(["info@codable.studio"])
                mailViewController.setSubject("Company info")
                self.present(mailViewController, animated: true)
            } else {
                self.showOneOptionAlert(title: "Alert", message: "Can not send email.", actionTitle: "OK")
            }
        }).disposed(by: disposeBag)
    }
    
    private func addBarButtonItem() {
        if navigationFromRegisterViewController {
            navigationItem.rightBarButtonItem = skipButton
        } else {
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func configureBackbuttonVisibility() {
        if navigationFromRegisterViewController {
            hideBackButton()
        }
    }

    private func showTitleInNavigationBar() {
        self.title = "Connect company"
    }
    
    private func hideBackButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}

// MARK: - UI rendering
private extension AddCompanyViewController {
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
    
    func renderCompanyPasscodeTextFieldAndSeparator() {
        containerView.addSubview(companyPassCodeTextField)
        companyPassCodeTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().inset(50)
        }
        companyPassCodeTextField.placeholder = "Enter company passcode"
        companyPassCodeTextField.autocorrectionType = .no
        companyPassCodeTextField.autocapitalizationType = .none
        companyPassCodeTextField.returnKeyType = .done
        
        containerView.addSubview(companyPassCodeSeparator)
        companyPassCodeSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(companyPassCodeTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(42)
            make.right.equalToSuperview().inset(42)
            make.height.equalTo(1)
        }
        companyPassCodeSeparator.backgroundColor = UIColor.unpauseLightGray
    }
    
    func renderAddCompanyButton() {
        containerView.addSubview(addCompanyButton)
        addCompanyButton.snp.makeConstraints { make in
            make.top.equalTo(companyPassCodeSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(50)
        }
        addCompanyButton.layer.cornerRadius = 25
    }
    
    
    func renderDescriptionLabel() {
        containerView.addSubview(descriptionButton)
        
        descriptionButton.snp.makeConstraints { make in
            make.top.equalTo(addCompanyButton.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview()
        }
        descriptionButton.setTitle("Please ask your manager for your company passcode or contact us at info@codable.studio for help.", for: .normal)
        descriptionButton.setTitleColor(.unpauseGray, for: .normal)
        descriptionButton.titleLabel?.numberOfLines = 0
        descriptionButton.titleLabel?.font = descriptionButton.titleLabel?.font.withSize(15)
        descriptionButton.titleLabel?.textAlignment = .center
    }
}

//MARK: - MFMailComposeViewController delegate
extension AddCompanyViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled")
            
        case MFMailComposeResult.saved.rawValue:
            UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
            
        case MFMailComposeResult.sent.rawValue:
            UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
            
        case MFMailComposeResult.failed.rawValue:
            showOneOptionAlert(title: "Alert", message: error!.localizedDescription, actionTitle: "OK")
            
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
