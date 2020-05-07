//
//  DescriptionViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift

class DescriptionViewController: UIViewController {
    
    private let descriptionViewModel: DescriptionViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let whatDidYouWorkOnLabel = UILabel()
    
    private let firstSuggestionButton = OrangeButton(title: "Develop")
    private let secondSuggestionButton = OrangeButton(title: "UI")
    private let thirdSuggestionButton = OrangeButton(title: "Testing")
    private let fourthSuggestionButton = OrangeButton(title: "Bugs")
    private let fifthSuggestionButton = OrangeButton(title: "Location")
    
    private let descriptionTextView = UITextView()
    
    private let stackView = UIStackView()
    private let cancelButton = OrangeButton(title: "Cancle")
    private let saveButton = OrangeButton(title: "Save")
    
    var shiftToEdit = PublishSubject<ShiftsTableViewItem>()
    
    let navigationFromTableView: Bool
    
    init(descriptionViewModel: DescriptionViewModelProtocol, navigationFromTableView: Bool) {
        self.navigationFromTableView = navigationFromTableView
        self.descriptionViewModel = descriptionViewModel
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
        setUpFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        HomeViewModel.forceRefresh.onNext(())
    }
    
    private func render() {
        configureScrollViewAndContainerView()
        renderWhatDidYouWorkOnLabel()
        renderSuggestionsButtonArray()
        renderTextView()
        renderCancelAndSaveButton()
    }
    
    private func setUpObservables() {
        descriptionTextView.rx.text
            .bind(to: descriptionViewModel.textInEmailTextFieldChanges)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap.subscribe(onNext: { _ in
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        handleSaveButtonTap()
        
        descriptionViewModel.shiftSavingResponse
            .subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    NotificationManager.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["notifyOnExit"])
                    NotificationManager.shared.scheduleEntranceNotification()
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    ActivityViewModel.forceRefresh.onNext(())
                    self.dismiss(animated: true)
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    self.showOneOptionAlert(title: "Error", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        descriptionViewModel.shiftEditingResponse
            .subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    ActivityViewModel.forceRefresh.onNext(())
                    self.dismiss(animated: true)
                case .error(let error):
                    UnpauseActivityIndicatorView.shared.dissmis(from: self.view)
                    self.showOneOptionAlert(title: "Error", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
        
        firstSuggestionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            guard let stringToAppend = self.firstSuggestionButton.titleLabel?.text else { return }
            self.descriptionTextView.text.append(contentsOf: stringToAppend)
        }).disposed(by: disposeBag)
        
        secondSuggestionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            guard let stringToAppend = self.secondSuggestionButton.titleLabel?.text else { return }
            self.descriptionTextView.text.append(contentsOf: stringToAppend)
        }).disposed(by: disposeBag)
        
        thirdSuggestionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            guard let stringToAppend = self.thirdSuggestionButton.titleLabel?.text else { return }
            self.descriptionTextView.text.append(contentsOf: stringToAppend)
        }).disposed(by: disposeBag)
        
        fourthSuggestionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            guard let stringToAppend = self.fourthSuggestionButton.titleLabel?.text else { return }
            self.descriptionTextView.text.append(contentsOf: stringToAppend)
        }).disposed(by: disposeBag)
        
        fifthSuggestionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            guard let stringToAppend = self.fifthSuggestionButton.titleLabel?.text else { return }
            self.descriptionTextView.text.append(contentsOf: stringToAppend)
        }).disposed(by: disposeBag)
    }
    
    func handleSaveButtonTap() {
        if navigationFromTableView {
            saveButton.rx.tap
                .do(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.dismissKeyboard()
                    UnpauseActivityIndicatorView.shared.show(on: self.view)
                })
                .bind(to: descriptionViewModel.saveButtonFromTableViewTapped)
                .disposed(by: disposeBag)
        } else {
            saveButton.rx.tap
                .do(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.dismissKeyboard()
                    UnpauseActivityIndicatorView.shared.show(on: self.view)
                })
                .bind(to: descriptionViewModel.saveButtonTapped)
                .disposed(by: disposeBag)
        }
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func setUpFirstResponder() {
        descriptionTextView.becomeFirstResponder()
    }
    
    private func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: - UI rendering
private extension DescriptionViewController {
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
    
    func renderWhatDidYouWorkOnLabel() {
        containerView.addSubview(whatDidYouWorkOnLabel)
        
        whatDidYouWorkOnLabel.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
        }
        whatDidYouWorkOnLabel.font = .systemFont(ofSize: 20)
        whatDidYouWorkOnLabel.text = "What did you work on?"
    }
    
    func renderSuggestionsButtonArray() {
        containerView.addSubview(firstSuggestionButton)
        
        firstSuggestionButton.snp.makeConstraints { make in
            make.top.equalTo(whatDidYouWorkOnLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.width.equalTo((UIScreen.main.bounds.width - 6 * 10) / 5)
            make.height.equalTo(25)
        }
        firstSuggestionButton.titleLabel?.font = .systemFont(ofSize: 12)
        firstSuggestionButton.layer.cornerRadius = 12.5
        
        containerView.addSubview(secondSuggestionButton)
        
        secondSuggestionButton.snp.makeConstraints { make in
            make.top.equalTo(whatDidYouWorkOnLabel.snp.bottom).offset(15)
            make.left.equalTo(firstSuggestionButton.snp.right).offset(10)
            make.width.equalTo((UIScreen.main.bounds.width - 6 * 10) / 5)
            make.height.equalTo(25)
        }
        secondSuggestionButton.titleLabel?.font = .systemFont(ofSize: 12)
        secondSuggestionButton.layer.cornerRadius = 12.5
        
        containerView.addSubview(thirdSuggestionButton)
        
        thirdSuggestionButton.snp.makeConstraints { make in
            make.top.equalTo(whatDidYouWorkOnLabel.snp.bottom).offset(15)
            make.left.equalTo(secondSuggestionButton.snp.right).offset(10)
            make.width.equalTo((UIScreen.main.bounds.width - 6 * 10) / 5)
            make.height.equalTo(25)
        }
        thirdSuggestionButton.titleLabel?.font = .systemFont(ofSize: 12)
        thirdSuggestionButton.layer.cornerRadius = 12.5
        
        containerView.addSubview(fourthSuggestionButton)
        
        fourthSuggestionButton.snp.makeConstraints { make in
            make.top.equalTo(whatDidYouWorkOnLabel.snp.bottom).offset(15)
            make.left.equalTo(thirdSuggestionButton.snp.right).offset(10)
            make.width.equalTo((UIScreen.main.bounds.width - 6 * 10) / 5)
            make.height.equalTo(25)
        }
        fourthSuggestionButton.titleLabel?.font = .systemFont(ofSize: 12)
        fourthSuggestionButton.layer.cornerRadius = 12.5
        
        containerView.addSubview(fifthSuggestionButton)
        
        fifthSuggestionButton.snp.makeConstraints { make in
            make.top.equalTo(whatDidYouWorkOnLabel.snp.bottom).offset(15)
            make.left.equalTo(fourthSuggestionButton.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
            make.width.equalTo((UIScreen.main.bounds.width - 6 * 10) / 5)
            make.height.equalTo(25)
        }
        fifthSuggestionButton.titleLabel?.font = .systemFont(ofSize: 12)
        fifthSuggestionButton.layer.cornerRadius = 12.5
    }
    
    func renderTextView() {
        containerView.addSubview(descriptionTextView)
        
        descriptionTextView.snp.makeConstraints { (make) in
            make.top.equalTo(fifthSuggestionButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(200)
        }
        descriptionTextView.backgroundColor = UIColor.unpauseWhite
        descriptionTextView.font = .systemFont(ofSize: 18)
        descriptionTextView.autocorrectionType = .no
        descriptionTextView.autocapitalizationType = .sentences
        descriptionTextView.returnKeyType = .default
    }
    
    func renderCancelAndSaveButton() {
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(saveButton)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        cancelButton.layer.cornerRadius = 15
        saveButton.layer.cornerRadius = 15
    }
}
