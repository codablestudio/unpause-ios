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
    private let networking = LoginNetworking()
    
    private var textInEmailTextField: String?
    private var textInPasswordTextField: String?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInPasswordTextFieldChanges = PublishSubject<String?>()
    var forgotPasswordButtonTapped = PublishSubject<Void>()
    var signInWithGoogleButtonTapped = PublishSubject<Void>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    var error = PublishSubject<Error>()
    var responseFromFirebase: Observable<FirebaseResponseObject>?
    
    var loginRequest: Observable<FirebaseResponseObject>!
    
    init() {
        setUpObservables()
        
        loginRequest = logInButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<FirebaseResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                
                let email = self.textInEmailTextField ?? ""
                let password = self.textInPasswordTextField ?? ""
                
                return self.networking.signInUserWith(email: email, password: password)
            })
            .do(onNext: { response in
                switch response {
                case .authDataResult(let authDataResult):
                    if let email = authDataResult.user.email {
                        let newUser = User()
                        newUser.email = email
                        SessionManager.shared.logIn(newUser)
                    }
                default: break
                }
            })
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
    }
}
