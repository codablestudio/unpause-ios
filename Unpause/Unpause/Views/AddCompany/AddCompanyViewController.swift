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
    
    private let companyPassCodeTextField = UITextField()
    private let companyPassCodeSeparator = UIView()
    
    private let addCompanyButton = OrangeButton(title: "Connect company")
    
    private let emailLabel = UILabel()
    private let descriptionButton = UIButton()
    
    private let skipButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: nil)
    
    private let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    
    var navigationFromRegisterViewController: Bool
    var navigationFromSettingsViewController = false
    var isPresentedViewController = false
    
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
        configureBackbuttonVisibility()
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderCompanyPasscodeTextFieldAndSeparator()
        renderAddCompanyButton()
        configureEmailLabelAppearance()
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
                    if self.navigationFromSettingsViewController {
                        self.navigationController?.popViewController(animated: true)
                    } else if self.navigationFromRegisterViewController {
                        self.dismiss(animated: true) {
                            Coordinator.shared.navigateToHomeViewController()
                        }
                    } else if self.isPresentedViewController {
                        self.dismiss(animated: true)
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
                mailViewController.setPreferredSendingEmailAddress(SessionManager.shared.getCurrentUserEmail())
                self.present(mailViewController, animated: true)
            } else {
                self.showOneOptionAlert(title: "Alert", message: "Can not send email.", actionTitle: "OK")
            }
        }).disposed(by: disposeBag)
    }
    
    private func addBarButtonItem() {
        if navigationFromRegisterViewController {
            navigationItem.rightBarButtonItem = skipButton
        } else if isPresentedViewController {
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
        if SessionManager.shared.currentUserHasConnectedCompany() {
            self.title = "Change company"
        } else {
            self.title = "Connect company"
        }
        navigationItem.largeTitleDisplayMode = .never
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
        if SessionManager.shared.currentUserHasConnectedCompany() {
            addCompanyButton.setTitle("Change company", for: .normal)
        }
    }
    
    func configureEmailLabelAppearance() {
        emailLabel.text = "info@codable.studio"
        emailLabel.textColor = .unpauseBlue
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
        makeEmailPartOfStringBlue()
    }
    
    func makeEmailPartOfStringBlue() {
        let blueString = "info@codable.studio"
        let range = ((descriptionButton.titleLabel?.text)! as NSString).range(of: blueString)

        let attributedText = NSMutableAttributedString.init(string: (descriptionButton.titleLabel?.text)!)
        attributedText.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue,
        NSAttributedString.Key.foregroundColor : UIColor.unpauseBlue], range: range)
        descriptionButton.titleLabel?.attributedText = attributedText
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
