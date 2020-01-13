//
//  UpdatePersonalInfoViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 07/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class UpdatePersonalInfoViewController: UIViewController {
    
    private let updatePersonalInfoViewModel: UpdatePersonalInfoViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let newFirstNameTextField = UITextField()
    private let newFirstNameSeparator = UIView()
    
    private let newLastNameTextField = UITextField()
    private let newLastNameSeparator = UIView()
    
    private let updateInfoButton = OrangeButton(title: "Update info")
    
    private let closeButton = UIButton()
    
    init(updatePersonalInfoViewModel: UpdatePersonalInfoViewModel) {
        self.updatePersonalInfoViewModel = updatePersonalInfoViewModel
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
        renderNewFirstNameTextFieldAndNewFirstNameSeparator()
        renderNewLastNameTextFieldAndNewLastNameSeparator()
        renderUpdateInfoButton()
        renderCloseButton()
    }
    
    private func setUpObservables() {
        newFirstNameTextField.rx.text
            .startWith(newFirstNameTextField.text)
            .bind(to: updatePersonalInfoViewModel.textInNewFirstNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        newLastNameTextField.rx.text
            .startWith(newLastNameTextField.text)
            .bind(to: updatePersonalInfoViewModel.textInNewLastNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        updateInfoButton.rx.tap
            .do(onNext: { _ in
                SVProgressHUD.dismiss()
            })
            .bind(to: updatePersonalInfoViewModel.updateInfoButtonTapped)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        updatePersonalInfoViewModel.updateInfoResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    SVProgressHUD.showSuccess(withStatus: "Info updated successfully")
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
            }).disposed(by: disposeBag)
    }
    
    private func showAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func setUpTextFields() {
        newFirstNameTextField.setNextResponder(newLastNameTextField, disposeBag: disposeBag)
        newLastNameTextField.resignWhenFinished(disposeBag)
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] (tapGesture) in
            self?.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
}

// MARK: - UI rendering

private extension UpdatePersonalInfoViewController {
    
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
    
    func renderNewFirstNameTextFieldAndNewFirstNameSeparator() {
        containerView.addSubview(newFirstNameTextField)
        newFirstNameTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(260)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().inset(35)
        }
        newFirstNameTextField.placeholder = "Enter new first name"
        newFirstNameTextField.autocorrectionType = .no
        newFirstNameTextField.autocapitalizationType = .words
        newFirstNameTextField.text = SessionManager.shared.currentUser?.firstName
        
        containerView.addSubview(newFirstNameSeparator)
        newFirstNameSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(newFirstNameTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(1)
        }
        newFirstNameSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderNewLastNameTextFieldAndNewLastNameSeparator() {
        containerView.addSubview(newLastNameTextField)
        newLastNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(newFirstNameSeparator.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().inset(35)
        }
        newLastNameTextField.placeholder = "Enter new last name"
        newLastNameTextField.autocorrectionType = .no
        newLastNameTextField.autocapitalizationType = .words
        newLastNameTextField.text = SessionManager.shared.currentUser?.lastName
        
        containerView.addSubview(newLastNameSeparator)
        newLastNameSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(newLastNameTextField.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(1)
        }
        newLastNameSeparator.backgroundColor = UIColor.lightGray
    }
    
    func renderUpdateInfoButton() {
        containerView.addSubview(updateInfoButton)
        updateInfoButton.snp.makeConstraints { (make) in
            make.top.equalTo(newLastNameSeparator.snp.bottom).offset(70)
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
