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
    
    let disposeBag = DisposeBag()
    
    var textInEmailTextField = PublishSubject<String?>()
    var textInPasswordTextField = PublishSubject<String?>()
    var forgotPasswordButtonTapped = PublishSubject<Void>()
    var signInWithGoogleButtonTapped = PublishSubject<Void>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInEmailTextField.subscribe(onNext: { (newValue) in
        }).disposed(by: disposeBag)
        
        textInPasswordTextField.subscribe(onNext: { (newValue) in
            }).disposed(by: disposeBag)
        
        forgotPasswordButtonTapped.subscribe(onNext: { _ in
        // TODO: Do networking for forgot password
        }).disposed(by: disposeBag)
        
        signInWithGoogleButtonTapped.subscribe(onNext: { _ in
            // TODO: Do networking for sign in with Google
            }).disposed(by: disposeBag)
        
        logInButtonTapped.subscribe(onNext: { (newValue) in
            // TODO: Do networking for log in
            }).disposed(by: disposeBag)
        
        registerNowButtonTapped.subscribe(onNext: { _ in
        // TODO: Do networking for register now
        }).disposed(by: disposeBag)
    }
}
