//
//  RegisterNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 29/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import Firebase
import FirebaseAuth
import FirebaseFirestore
import RxFirebase
import GoogleSignIn

protocol RegisterNetworkingProtocol {
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) -> Observable<FirebaseResponseObject>
    func signInGoogleUser(googleUser: GIDGoogleUser) -> Observable<FirebaseResponseObject>
    func saveUserInfoOnServer(email: String, firstName: String, lastName: String) -> Observable<Response>
    func checkIfUserIsAlreadyInDatabase(email: String) -> Observable<GoogleUserResponse>
    func saveUserOnServerAndReturnUserDocument(email: String, firstName: String, lastName: String) -> Observable<FirebaseDocumentResponseObject>
}

class RegisterNetworking: RegisterNetworkingProtocol {
    
    private let dataBaseReference = Firestore.firestore()
    
    private var privateAuthDataResult: AuthDataResult?
    
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) -> Observable<FirebaseResponseObject> {
        Auth.auth().rx.createUser(withEmail: email, password: password)
            .flatMapLatest ({ [weak self] authDataResult -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                self.privateAuthDataResult = authDataResult
                return self.saveUserInfoOnServer(email: email, firstName: firstName, lastName: lastName)
            }).catchError ({ error -> Observable<Response> in
                return Observable.just(Response.error(.otherError(error)))
            })
            .flatMapLatest { [weak self] response -> Observable<FirebaseResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                guard let authDataResult = self.privateAuthDataResult else {
                    return Observable.just(FirebaseResponseObject.error(.emptyError))
                }
                switch response {
                case .success:
                    let newUser = User(firstName: firstName, lastName: lastName, email: email)
                    SessionManager.shared.logIn(newUser)
                    return Observable.just(FirebaseResponseObject.success(authDataResult))
                case .error(let error):
                    return Observable.just(FirebaseResponseObject.error(error))
                }
        }
    }
    
    func signInGoogleUser(googleUser: GIDGoogleUser) -> Observable<FirebaseResponseObject> {
        guard let idToken = googleUser.authentication.idToken,
            let accessToken = googleUser.authentication.accessToken else {
                return Observable.just(FirebaseResponseObject.error(.emptyError))
        }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return Auth.auth().rx.signInAndRetrieveData(with: credentials)
            .flatMapLatest ({ authDataResult -> Observable<FirebaseResponseObject> in
                return Observable.just(FirebaseResponseObject.success(authDataResult))
            })
            .catchError ({ error -> Observable<FirebaseResponseObject> in
                return Observable.just(FirebaseResponseObject.error(.otherError(error)))
            })
    }
    
    func checkIfUserIsAlreadyInDatabase(email: String) -> Observable<GoogleUserResponse> {
        return dataBaseReference
            .collection("users")
            .document("\(email)")
            .rx
            .getDocument()
            .flatMapLatest ({ documentSnapshot -> Observable<GoogleUserResponse> in
                if documentSnapshot.exists {
                    return Observable.just(GoogleUserResponse.exsistingUser(documentSnapshot))
                } else {
                    return Observable.just(GoogleUserResponse.notExistingUser)
                }
            })
            .catchError ({ error -> Observable<GoogleUserResponse> in
                let firebaseError = error as NSError
                if  firebaseError.code == 5 {
                    return Observable.just(GoogleUserResponse.notExistingUser)
                } else {
                    return Observable.just(GoogleUserResponse.error(.otherError(error)))
                }
            })
    }
    
    func saveUserOnServerAndReturnUserDocument(email: String, firstName: String, lastName: String) -> Observable<FirebaseDocumentResponseObject> {
        return saveUserInfoOnServer(email: email, firstName: firstName, lastName: lastName)
            .flatMapLatest { [weak self] response -> Observable<FirebaseDocumentResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                switch response {
                case .success:
                    return self.checkIfUserIsAlreadyInDatabase(email: email)
                        .flatMapLatest { googleUserResponse -> Observable<FirebaseDocumentResponseObject> in
                            switch googleUserResponse {
                            case .exsistingUser(let documentSnapshot):
                                return Observable.just(FirebaseDocumentResponseObject.success(documentSnapshot))
                            case .notExistingUser:
                                return Observable.just(FirebaseDocumentResponseObject.error(.googleUserSignInError))
                            case .error(let error):
                                return Observable.just(FirebaseDocumentResponseObject.error(error))
                            }
                    }
                case .error(let error):
                    return Observable.just(FirebaseDocumentResponseObject.error(error))
                }
        }
        .catchError { error -> Observable<FirebaseDocumentResponseObject> in
            return Observable.just(FirebaseDocumentResponseObject.error(.otherError(error)))
        }
    }
    
    internal func saveUserInfoOnServer(email: String, firstName: String, lastName: String) -> Observable<Response> {
        return self.dataBaseReference
            .collection("users")
            .document("\(email)")
            .rx
            .setData(["firstName": "\(firstName)",
                "lastName": "\(lastName)",
                "email": "\(email)"], merge: true)
            .flatMapLatest ({ _ -> Observable<Response> in
                return Observable.just(Response.success)
            }).catchError ({ error -> Observable<Response> in
                return Observable.just(Response.error(.otherError(error)))
            })
    }
}
