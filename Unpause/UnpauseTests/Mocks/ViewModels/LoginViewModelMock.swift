//
//  LoginViewModelMock.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn

class LoginViewModelMock: LoginViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    
    private let loginNetworking: LoginNetworkingProtocol
    private let companyNetworking: CompanyNetworkingProtocol
    private let registerNetworking: RegisterNetworkingProtocol
    
    private var textInEmailTextField: String?
    private var textInPasswordTextField: String?
    private var privateUser: User?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInPasswordTextFieldChanges = PublishSubject<String?>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    var googleUserSignInResponse = PublishSubject<GIDGoogleUser>()
    var userHasCompany = PublishSubject<Bool>()
    
    var loginRequest: Observable<FirebaseResponseObject>!
    var loginDocument: Observable<UnpauseResponse>!
    var googleUserSavingResponse: Observable<UnpauseResponse>!
    var isInsideGoogleSignInFlow: Observable<Bool>!
    
    init(loginNetworking: LoginNetworkingProtocol,
         companyNetworking: CompanyNetworkingProtocol,
         registerNetworking: RegisterNetworkingProtocol) {
        self.loginNetworking = loginNetworking
        self.companyNetworking = companyNetworking
        self.registerNetworking = registerNetworking
        
        setUpObservables()
    }
    
    private func setUpObservables() {
        loginDocument = logInButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<FirebaseResponseObject> in
                guard let `self` = self,
                    let email = self.textInEmailTextField,
                    let password = self.textInPasswordTextField else {
                        return Observable.just(FirebaseResponseObject.error(.emptyError))
                }
                return self.loginNetworking.signInUserWith(email: email, password: password)
            })
            .flatMapLatest({ [weak self] firebaseResponseObject -> Observable<FirebaseDocumentResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                switch firebaseResponseObject {
                case .success(_):
                    return self.loginNetworking.getInfoFromUserWith(firebaseResponseObject: firebaseResponseObject)
                case .error(let error):
                    return Observable.just(FirebaseDocumentResponseObject.error(error))
                }
            })
            .map({ firebaseResponse -> UserResponse in
                switch firebaseResponse {
                case .success(let document):
                    do {
                        let newUser = try UserFactory.createUser(from: document)
                        SessionManager.shared.logIn(newUser)
                        return UserResponse.success(newUser)
                    } catch (let error) {
                        return UserResponse.error(.otherError(error))
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
                    return Observable.just(CompanyFetchingResponse.error(error))
                }
            })
            .map({ companyFetchingResponse -> UnpauseResponse in
                switch companyFetchingResponse {
                case .success(let company):
                    SessionManager.shared.currentUser?.company = company
                    SessionManager.shared.saveCurrentUserToUserDefaults()
                    return UnpauseResponse.success
                case .error(let error):
                    return UnpauseResponse.error(error)
                }
            })
        
        textInEmailTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInEmailTextField = newValue
        }).disposed(by: disposeBag)
        
        textInPasswordTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInPasswordTextField = newValue
        }).disposed(by: disposeBag)
    }
}
