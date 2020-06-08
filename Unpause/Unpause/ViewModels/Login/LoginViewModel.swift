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

class LoginViewModel: LoginViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let loginNetworking: LoginNetworkingProtocol
    private let companyNetworking: CompanyNetworkingProtocol
    private let registerNetworking: RegisterNetworkingProtocol
    private let locationNetworking: LocationNetworkingProtocol
    private let _isInsideGoogleSignInFlow = ActivityIndicator()
    
    private var textInEmailTextField: String?
    private var textInPasswordTextField: String?
    private var privateUser: User?
    
    private var googleUserEmail: String?
    private var googleUserFirstName: String?
    private var googleUserLastName: String?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInPasswordTextFieldChanges = PublishSubject<String?>()
    var logInButtonTapped = PublishSubject<Void>()
    var registerNowButtonTapped = PublishSubject<Void>()
    var googleUserSignInResponse = PublishSubject<GIDGoogleUser>()
    var isInsideGoogleSignInFlow: Observable<Bool>! {
        return _isInsideGoogleSignInFlow.asObservable()
    }
    
    var loginRequest: Observable<FirebaseResponseObject>!
    var loginDocument: Observable<UnpauseResponse>!
    var googleUserSavingResponse: Observable<UnpauseResponse>!
    
    init(loginNetworking: LoginNetworkingProtocol,
         companyNetworking: CompanyNetworkingProtocol,
         registerNetworking: RegisterNetworkingProtocol,
         locationNetworking: LocationNetworkingProtocol) {
        self.loginNetworking = loginNetworking
        self.companyNetworking = companyNetworking
        self.registerNetworking = registerNetworking
        self.locationNetworking = locationNetworking
        
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
            .flatMapLatest({ [weak self] unpauseResponse -> Observable<UnpauseResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.locationNetworking.fetchCurrentUsersLocationsAndSaveThemLocally()
            })
        
        textInEmailTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInEmailTextField = newValue
        }).disposed(by: disposeBag)
        
        textInPasswordTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInPasswordTextField = newValue
        }).disposed(by: disposeBag)
        
        googleUserSignInResponse.subscribe(onNext: { [weak self] googleUser in
            guard let `self` = self else { return }
            self.googleUserEmail = googleUser.profile.email
            self.googleUserFirstName = googleUser.profile.givenName
            self.googleUserLastName = googleUser.profile.familyName
        }).disposed(by: disposeBag)
        
        googleUserSavingResponse = googleUserSignInResponse
            .flatMapLatest({ googleUser -> Observable<FirebaseResponseObject> in
                return self.registerNetworking.signInGoogleUser(googleUser: googleUser)
                    .trackActivity(self._isInsideGoogleSignInFlow)
            })
            .flatMapLatest({ [weak self] firebaseResponseObject -> Observable<GoogleUserResponse> in
                guard let `self` = self,
                    let email = self.googleUserEmail else {
                        return Observable.just(GoogleUserResponse.error(.googleUserSignInError))
                }
                switch firebaseResponseObject {
                case .success(_):
                    return self.registerNetworking.checkIfUserIsAlreadyInDatabase(email: email)
                case .error(let error):
                    return Observable.just(GoogleUserResponse.error(error))
                }
            })
            .flatMapLatest({ [weak self] googleUserResponse -> Observable<FirebaseDocumentResponseObject> in
                guard let `self` = self,
                    let email = self.googleUserEmail,
                    let firstName = self.googleUserFirstName,
                    let lastName = self.googleUserLastName else {
                        return Observable.just(FirebaseDocumentResponseObject.error(.emptyError))
                }
                switch googleUserResponse {
                case .existingUser(let documentSnapshot):
                    return Observable.just(FirebaseDocumentResponseObject.success(documentSnapshot))
                case .notExistingUser:
                    return self.registerNetworking.saveUserOnServerAndReturnUserDocument(email: email, firstName: firstName, lastName: lastName)
                case .error(let error):
                    return Observable.just(FirebaseDocumentResponseObject.error(error))
                }
            })
            .flatMapLatest({ firebaseDocumentResponseObject -> Observable<FirebaseDocumentResponseObject> in
                switch firebaseDocumentResponseObject {
                case .success(let documentSnapshot):
                    return Observable.just(FirebaseDocumentResponseObject.success(documentSnapshot))
                case .error(let unpauseError):
                    return Observable.just(FirebaseDocumentResponseObject.error(unpauseError))
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
            .flatMapLatest({ [weak self] unpauseResponse -> Observable<UnpauseResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.locationNetworking.fetchCurrentUsersLocationsAndSaveThemLocally()
            })
    }
}
