//
//  DescriptionViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class DescriptionViewController: UIViewController {
    
    private let descriptionViewModel: DescriptionViewModel
    private let disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let whatDidYouWorkOnLabel = UILabel()
    
    private let descriptionTextView = UITextView()
    
    private let stackView = UIStackView()
    private let cancelButton = OrangeButton(title: "Cancle")
    private let saveButton = OrangeButton(title: "Save")
    
    init(descriptionViewModel: DescriptionViewModel) {
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
        
        saveButton.rx.tap
            .do(onNext: { _ in
                SVProgressHUD.show()
            })
            .bind(to: descriptionViewModel.saveButtonTapped)
            .disposed(by: disposeBag)
        
        descriptionViewModel.shiftSavingResponse
            .subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                switch response {
                case .success:
                    SVProgressHUD.showSuccess(withStatus: "Shift successfully added.")
                    SVProgressHUD.dismiss(withDelay: 0.6)
                    ActivityViewModel.forceRefresh.onNext(())
                    self.dismiss(animated: true)
                case .error(let error):
                    self.showAlert(title: "Error", message: "\(error.localizedDescription)", actionTitle: "OK")
                }
            }).disposed(by: disposeBag)
    }
    
    private func addGestureRecognizer() {
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    private func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func showAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - UI rendering

private extension DescriptionViewController {
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
    
    func renderWhatDidYouWorkOnLabel() {
        containerView.addSubview(whatDidYouWorkOnLabel)
        
        whatDidYouWorkOnLabel.snp.makeConstraints { (make) in
            make.topMargin.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
        }
        whatDidYouWorkOnLabel.font = .systemFont(ofSize: 20)
        whatDidYouWorkOnLabel.text = "What did you work on?"
    }
    
    func renderTextView() {
        containerView.addSubview(descriptionTextView)
        
        descriptionTextView.snp.makeConstraints { (make) in
            make.top.equalTo(whatDidYouWorkOnLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(200)
        }
        descriptionTextView.backgroundColor = UIColor.whiteUnpauseTextAndBackgroundColor
        descriptionTextView.font = .systemFont(ofSize: 18)
        descriptionTextView.autocorrectionType = .no
        descriptionTextView.autocapitalizationType = .sentences
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
    }
}
