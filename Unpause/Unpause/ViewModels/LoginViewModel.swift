//
//  LoginViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 11/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    private let disposeBag = DisposeBag()
    private let networking = Networking()
    private var textInEmailTextField: String?
    private var textInPasswordTextField: String?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInPasswordTextFieldChanges = PublishSubject<String?>()
    var forgotPasswordButtonTapped = PublishSubject<Void>()
    var signInWithGoogleButtonTapped = PublishSubject<Void>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    var someFieldsAreEmpty = PublishSubject<Bool>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInEmailTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInEmailTextField = newValue
        }).disposed(by: disposeBag)
        
        textInPasswordTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInPasswordTextField = newValue
        }).disposed(by: disposeBag)
        
        forgotPasswordButtonTapped.subscribe(onNext: { _ in
            // TODO: Do networking for forgot password
        }).disposed(by: disposeBag)
        
        signInWithGoogleButtonTapped.subscribe(onNext: { _ in
            // TODO: Do networking for sign in with Google
        }).disposed(by: disposeBag)
        
        logInButtonTapped.subscribe(onNext: { [weak self] _ in
            guard let email = self?.textInEmailTextField,
                let password = self?.textInPasswordTextField,
                !email.isEmpty,
                !password.isEmpty else {
                    self?.someFieldsAreEmpty.onNext(true)
                    return
            }
            self?.networking.signInUserWith(email: email, password: password)
        }).disposed(by: disposeBag)
        
        registerNowButtonTapped.subscribe(onNext: { _ in
            // TODO: Do networking for register now
        }).disposed(by: disposeBag)
    }
}
