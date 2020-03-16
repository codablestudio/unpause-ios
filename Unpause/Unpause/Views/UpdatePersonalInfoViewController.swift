//
//  UpdatePersonalInfoViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 07/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class UpdatePersonalInfoViewController: UIViewController {
    
    private let updatePersonalInfoViewModel: UpdatePersonalInfoViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let updatePersonalInfoLabel = UILabel()
    private let updatePersonalInfoSeparator = UIView()
    
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
        renderupdatePersonalInfoLabelAndSeparator()
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
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                ActivityIndicatorView.shared.show(on: self.view)
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
                    ActivityIndicatorView.shared.dissmis()
                    self.dismiss(animated: true)
                case .error(let error):
                    if let error = error as? UnpauseError, error == UnpauseError.emptyError {
                        self.showAlert(title: "Error", message: "Please fill empty fields.", actionTitle: "OK")
                    } else {
                        self.showAlert(title: "Error", message: error.localizedDescription, actionTitle: "OK")
                    }
                    ActivityIndicatorView.shared.dissmis()
                }
            }).disposed(by: disposeBag)
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
    
    func renderupdatePersonalInfoLabelAndSeparator() {
        containerView.addSubview(updatePersonalInfoLabel)
        updatePersonalInfoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        updatePersonalInfoLabel.text = "Change personal info"
        updatePersonalInfoLabel.textColor = UIColor.orange
        updatePersonalInfoLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        containerView.addSubview(updatePersonalInfoSeparator)
        updatePersonalInfoSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(updatePersonalInfoLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        updatePersonalInfoSeparator.backgroundColor = UIColor.orange
    }
    
    func renderNewFirstNameTextFieldAndNewFirstNameSeparator() {
        containerView.addSubview(newFirstNameTextField)
        newFirstNameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(updatePersonalInfoSeparator.snp.bottom).offset(80)
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
            make.top.equalTo(newLastNameSeparator.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        updateInfoButton.layer.cornerRadius = 25
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
