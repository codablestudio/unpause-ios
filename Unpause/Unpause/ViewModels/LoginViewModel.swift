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
import GoogleSignIn

class LoginViewModel {
    
    private let disposeBag = DisposeBag()
    private let loginNetworking = LoginNetworking()
    private let companyNetworking = CompanyNetworking()
    private let registerNetworking = RegisterNetworking()
    
    private var textInEmailTextField: String?
    private var textInPasswordTextField: String?
    private var privateUser: User?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInPasswordTextFieldChanges = PublishSubject<String?>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    var googleUserSignInResponse = PublishSubject<GIDGoogleUser>()
    
    var loginRequest: Observable<FirebaseResponseObject>!
    var loginDocument: Observable<UnpauseResponse>!
    var googleUserSavingResponse: Observable<Response>!
    
    init() {
        setUpObservables()
        
        loginDocument = logInButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<FirebaseResponseObject> in
                guard let `self` = self,
                    let email = self.textInEmailTextField,
                    let password = self.textInPasswordTextField else {
                        return Observable.just(FirebaseResponseObject.error(UnpauseError.emptyError))
                }
                return self.loginNetworking.signInUserWith(email: email, password: password)
            })
            .flatMapLatest({ [weak self] firebaseResponseObject -> Observable<FirebaseDocumentResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                return self.loginNetworking.getInfoFromUserWith(firebaseResponseObject: firebaseResponseObject)
            })
            .map({ firebaseResponse -> UserResponse in
                switch firebaseResponse {
                case .success(let document):
                    do {
                        let newUser = try UserFactory.createUser(from: document)
                        SessionManager.shared.logIn(newUser)
                        return UserResponse.success(newUser)
                    } catch (let error) {
                        return UserResponse.error(error)
                    }
                case .error(let error):
                    return UserResponse.error(error)
                }
            })
            .flatMapLatest({ [weak self] userResponse -> Observable<CompanyFetchingResponse> in
                guard let `self` = self else { return Observable.empty() }
                switch userResponse {
                case .success(let user):
                    self.privateUser = user
                    return self.companyNetworking.fetchCompany()
                case .error(let error):
                    return Observable.just(CompanyFetchingResponse.error(UnpauseError.otherError(error)))
                }
            })
            .map({ companyFetchingResponse -> UnpauseResponse in
                switch companyFetchingResponse {
                case .success(let company):
                    SessionManager.shared.currentUser?.company = company
                    SessionManager.shared.saveCurrentUserToUserDefaults()
                    return UnpauseResponse.success
                case .error(let error):
                    return UnpauseResponse.error(UnpauseError.otherError(error))
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
        
        googleUserSavingResponse = googleUserSignInResponse
            .flatMapLatest({ [weak self] googleUser -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                return self.registerNetworking.signInGoogleUser(googleUser: googleUser)
            })
    }
}
