//
//  BossInfoViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 26/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class BossInfoViewController: UIViewController {
    
    private let bossInfoViewModel: BossInfoViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let settingBossInfoLabel = UILabel()
    private let settingBossInfoSeparator = UIView()
    
    private let bossFirstNameTextField = UITextField()
    private let bossFirstNameSeparator = UIView()
    
    private let bossLastNameTextField = UITextField()
    private let bossLastNameSeparator = UIView()
    
    private let bossEmailTextField = UITextField()
    private let bossEmailSeparator = UIView()
    
    private let saveButton = OrangeButton(title: "Save")
    
    private let closeButton = UIButton()
    
    private let activityStarted = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        setUpObservables()
        setUpTextFields()
        activityStarted.onNext(())
    }
    
    init(bossInfoViewModel: BossInfoViewModel) {
        self.bossInfoViewModel = bossInfoViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderSettingBossInfoLabelAndSeparator()
        renderBossFirstNameTextFieldAndSeparator()
        renderBossLastNameTextFieldAndSeparator()
        renderBossEmailTextFieldAndSeparator()
        renderSaveButton()
        renderCloseButton()
    }
    
    private func setUpObservables() {
        closeButton.rx.tap
            .subscribe(onNext: { _ in
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        saveButton.rx.tap
            .do(onNext: { _ in
                SVProgressHUD.show()
            })
            .bind(to: bossInfoViewModel.saveButtonTouched)
            .disposed(by: disposeBag)
        
        bossFirstNameTextField.rx.text
            .bind(to: bossInfoViewModel.textInBossFirstNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        bossLastNameTextField.rx.text
            .bind(to: bossInfoViewModel.textInBossLastNameTextFieldChanges)
            .disposed(by: disposeBag)
        
        bossEmailTextField.rx.text
            .bind(to: bossInfoViewModel.textInBossEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        activityStarted
            .bind(to: bossInfoViewModel.activityStarted)
            .disposed(by: disposeBag)
        
        
        bossInfoViewModel.bossSavingResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                
                switch response {
                case .success:
                    SVProgressHUD.showSuccess(withStatus: "Boss successfully added.")
                    SVProgressHUD.dismiss(withDelay: 0.6)
                    self.dismiss(animated: true)
                case .error(let error):
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Alert", message: error.localizedDescription, actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        bossInfoViewModel.bossFetchingResponse
            .subscribe(onNext: { [weak self] bossFetchingResponse in
                guard let `self` = self else { return }
                
                switch bossFetchingResponse {
                case .success(let boss):
                    SessionManager.shared.currentUser?.boss = boss
                case .error(_):
                    self.showAlert(title: "Error", message: "Error fetching boss info.", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
    }
    
    private func setUpTextFields() {
        bossFirstNameTextField.setNextResponder(bossLastNameTextField, disposeBag: disposeBag)
        bossLastNameTextField.setNextResponder(bossEmailTextField, disposeBag: disposeBag)
        bossEmailTextField.resignWhenFinished(disposeBag)
    }
}
// MARK: - UI rendering
private extension BossInfoViewController {
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
    
    func renderSettingBossInfoLabelAndSeparator() {
        containerView.addSubview(settingBossInfoLabel)
        settingBossInfoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        settingBossInfoLabel.text = "Setting boss`s info"
        settingBossInfoLabel.textColor = UIColor.orange
        settingBossInfoLabel.font = UIFont.boldSystemFont(ofSize: 25)

        containerView.addSubview(settingBossInfoSeparator)
        settingBossInfoSeparator.snp.makeConstraints { (make) in
            make.top.equalTo(settingBossInfoLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(1)
        }
        settingBossInfoSeparator.backgroundColor = UIColor.orange
    }
    
    func renderBossFirstNameTextFieldAndSeparator() {
        containerView.addSubview(bossFirstNameTextField)
        
        bossFirstNameTextField.snp.makeConstraints { make in
            make.top.equalTo(settingBossInfoSeparator.snp.bottom).offset(80)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().inset(35)
        }
        bossFirstNameTextField.placeholder = "Enter boss`s first name"
        bossFirstNameTextField.autocorrectionType = .no
        bossFirstNameTextField.autocapitalizationType = .words
        
        containerView.addSubview(bossFirstNameSeparator)
        
        bossFirstNameSeparator.snp.makeConstraints { make in
            make.top.equalTo(bossFirstNameTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(1)
        }
        bossFirstNameSeparator.backgroundColor = .lightGray
    }
    
    func renderBossLastNameTextFieldAndSeparator() {
        containerView.addSubview(bossLastNameTextField)
        
        bossLastNameTextField.snp.makeConstraints { make in
            make.top.equalTo(bossFirstNameSeparator.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().inset(35)
        }
        bossLastNameTextField.placeholder = "Enter boss`s last name"
        bossLastNameTextField.autocorrectionType = .no
        bossLastNameTextField.autocapitalizationType = .words
        
        containerView.addSubview(bossLastNameSeparator)
        
        bossLastNameSeparator.snp.makeConstraints { make in
            make.top.equalTo(bossLastNameTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(1)
        }
        bossLastNameSeparator.backgroundColor = .lightGray
    }
    
    func renderBossEmailTextFieldAndSeparator() {
        containerView.addSubview(bossEmailTextField)
        
        bossEmailTextField.snp.makeConstraints { make in
            make.top.equalTo(bossLastNameSeparator.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview().inset(35)
        }
        bossEmailTextField.placeholder = "Enter boss`s email"
        bossEmailTextField.autocorrectionType = .no
        bossEmailTextField.autocapitalizationType = .none
        bossEmailTextField.keyboardType = .emailAddress
        
        containerView.addSubview(bossEmailSeparator)
        
        bossEmailSeparator.snp.makeConstraints { make in
            make.top.equalTo(bossEmailTextField.snp.bottom).offset(7)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
            make.height.equalTo(1)
        }
        bossEmailSeparator.backgroundColor = .lightGray
    }
    
    func renderSaveButton() {
        containerView.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(bossEmailSeparator.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().inset(33)
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
