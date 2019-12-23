//
//  LoginViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 11/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import RxFirebase
import FirebaseAuth

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
    var pushToHomeViewController = PublishSubject<Bool>()
    var error = PublishSubject<Error>()
    var responseFromFirebase: Observable<FirebaseResponseObject>?
    
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
        
        responseFromFirebase?.subscribe(onNext: { (authdDataResult) in
            if authdDataResult.authDataResult != nil {
                print("\((authdDataResult.authDataResult?.user.email)!)")
            }
        }).disposed(by: disposeBag)
        
        logInButtonTapped.subscribe(onNext: { [weak self] _ in
            guard let email = self?.textInEmailTextField,
                let password = self?.textInPasswordTextField else {
                    return
            }
            Auth.auth().rx.signIn(withEmail: email, password: password).subscribe(onNext: { [weak self] (authDataResult) in
                guard let email = authDataResult.user.email else { return }
                self?.pushToHomeViewController.onNext(true)
                User.sharedInstance.email = email
                }, onError: { error in
                    self?.error.onNext(error)
                    print("\(error)")
            }).disposed(by: self!.disposeBag)
            
            // self?.responseFromFirebase = self?.networking.signInUserWith(email: email, password: password)
        }).disposed(by: disposeBag)
        
        
    }
}
