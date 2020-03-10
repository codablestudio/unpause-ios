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
    var logInButtonTapped: PublishSubject<Void>  { get }
    var registerNowButtonTapped: PublishSubject<Void>  { get }
    
    var loginRequest: Observable<FirebaseResponseObject>! { get }
    var loginDocument: Observable<Response>! { get }
}

class LoginViewModel: LoginViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let loginNetworking = LoginNetworking()
    private let companyNetworking = CompanyNetworking()
    
    private var textInEmailTextField: String?
    private var textInPasswordTextField: String?
    private var privateUser: User?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInPasswordTextFieldChanges = PublishSubject<String?>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    
    var loginRequest: Observable<FirebaseResponseObject>!
    var loginDocument: Observable<Response>!
    
    init() {
        setUpObservables()
        
        loginDocument = logInButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<FirebaseResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                
                let email = self.textInEmailTextField ?? ""
                let password = self.textInPasswordTextField ?? ""
                
                return self.loginNetworking.signInUserWith(email: email, password: password)
            })
            .flatMapLatest({ [weak self] firebaseResponseObject -> Observable<FirebaseDocumentResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                return self.loginNetworking.getInfoFromUserWitha(firebaseResponseObject: firebaseResponseObject)
            })
            .map({ firebaseResponse -> UserResponse in
                switch firebaseResponse {
                case .success(let document):
                    do {
                        let newUser = try UserFactory.createUser(from: document)
                        SessionManager.shared.logIn(newUser)
                        return UserResponse.success(newUser)
                    } catch(let error) {
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
                case .error(let error):
                    print("ERROR: \(error.localizedDescription)")
                }
                return self.companyNetworking.fetchCompany()
            })
            .map({ companyFetchingResponse -> Response in
                switch companyFetchingResponse {
                case .success(let company):
                    SessionManager.shared.currentUser?.company = company
                    SessionManager.shared.logIn(SessionManager.shared.currentUser!)
                    return Response.success
                case .error(let error):
                    return Response.error(error)
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
    }
}
