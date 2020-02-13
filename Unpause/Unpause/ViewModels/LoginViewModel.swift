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
import FirebaseFirestore

protocol LoginViewModelProtocol {
    
    var textInEmailTextFieldChanges: PublishSubject<String?> { get }
    var textInPasswordTextFieldChanges: PublishSubject<String?>  { get }
    var forgotPasswordButtonTapped: PublishSubject<Void>  { get }
    var signInWithGoogleButtonTapped: PublishSubject<Void>  { get }
    var logInButtonTapped: PublishSubject<Void>  { get }
    var registerNowButtonTapped: PublishSubject<Void>  { get }
    
    var loginRequest: Observable<FirebaseResponseObject>! { get }
    var loginDocument: Observable<FirebaseDocumentResponseObject>! { get }
}

class LoginViewModel: LoginViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let loginNetworking = LoginNetworking()
    
    private var textInEmailTextField: String?
    private var textInPasswordTextField: String?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInPasswordTextFieldChanges = PublishSubject<String?>()
    var forgotPasswordButtonTapped = PublishSubject<Void>()
    var signInWithGoogleButtonTapped = PublishSubject<Void>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    
    var loginRequest: Observable<FirebaseResponseObject>!
    var loginDocument: Observable<FirebaseDocumentResponseObject>!
    
    init() {
        setUpObservables()
        
        loginDocument = logInButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<FirebaseResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                
                let email = self.textInEmailTextField ?? ""
                let password = self.textInPasswordTextField ?? ""
                
                return self.loginNetworking.signInUserWith(email: email, password: password)
            })
            .flatMapLatest({ [weak self] (firebaseResponseObject) -> Observable<FirebaseDocumentResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                return self.loginNetworking.getInfoFromUserWitha(firebaseResponseObject: firebaseResponseObject)
            })
            .map({ firebaseResponse -> FirebaseDocumentResponseObject in
                switch firebaseResponse {
                case .documentSnapshot(let document):
                    do {
                        let newUser = try UserFactory.createUser(from: document)
                        SessionManager.shared.logIn(newUser)
                    } catch(let error) {
                        return FirebaseDocumentResponseObject.error(error)
                    }
                    return firebaseResponse
                default:
                    return firebaseResponse
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
