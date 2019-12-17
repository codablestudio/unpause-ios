//
//  RegisterViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class RegisterViewModel {
    
    private let disposeBag = DisposeBag()
    private let networking = Networking()
    
    private var textInFirstNameTextField: String?
    private var textInLastNameTextField: String?
    private var textInEmailTextField: String?
    private var textInNewPasswordTextField: String?
    
    var textInFirstNameTextFieldChanges = PublishSubject<String?>()
    var textInLastNameTextFieldChanges = PublishSubject<String?>()
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInNewPasswordTextFieldChanges = PublishSubject<String?>()
    var registerButtonTapped = PublishSubject<Void>()
    var someFieldsAreEmpty = PublishSubject<Bool>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInFirstNameTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInFirstNameTextField = newValue
        }).disposed(by: disposeBag)
        
        textInLastNameTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInLastNameTextField = newValue
        }).disposed(by: disposeBag)
        
        textInEmailTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInEmailTextField = newValue
        }).disposed(by: disposeBag)
        
        textInNewPasswordTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInNewPasswordTextField = newValue
        }).disposed(by: disposeBag)
        
        registerButtonTapped.subscribe(onNext: { [weak self] _ in
            guard let firstName = self?.textInFirstNameTextField,
                let lastName = self?.textInLastNameTextField,
                let email = self?.textInEmailTextField,
                let password = self?.textInNewPasswordTextField,
                !firstName.isEmpty,
                !lastName.isEmpty,
                !email.isEmpty,
                !password.isEmpty else {
                    self?.someFieldsAreEmpty.onNext(true)
                    return
            }
            self?.networking.registerUserWith(firstName: firstName, lastName: lastName, email: email, password: password)
        }).disposed(by: disposeBag)
    }
}
