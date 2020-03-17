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

class RegisterNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) -> Observable<FirebaseResponseObject> {
        Auth.auth().rx.createUser(withEmail: email, password: password)
            .flatMapLatest { [weak self] (authDataResult) -> Observable<FirebaseResponseObject> in
                guard let `self` = self else { return Observable.empty() }
                guard let _ = authDataResult.user.email else {
                    return Observable.just(FirebaseResponseObject.error(UnpauseError.noUser))
                }
                return self.saveUserInfoOnServer(email: email, firstName: firstName, lastName: lastName)
                    .flatMapLatest ({ _ -> Observable<FirebaseResponseObject> in
                        return Observable.just(FirebaseResponseObject.success(authDataResult))
                    }).catchError ({ error -> Observable<FirebaseResponseObject> in
                        return Observable.just(FirebaseResponseObject.error(UnpauseError.otherError(error)))
                    })
        }
    }
    
    func signInGoogleUser(googleUser: GIDGoogleUser) -> Observable<Response> {
        guard let idToken = googleUser.authentication.idToken,
            let accessToken = googleUser.authentication.accessToken else {
                return Observable.just(Response.error(UnpauseError.emptyError))
        }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return Auth.auth().rx.signInAndRetrieveData(with: credentials)
            .flatMapLatest { authDataResult -> Observable<Response> in
                guard let userEmail = authDataResult.user.email,
                    let userFirstName = googleUser.profile.givenName,
                    let userLastName = googleUser.profile.familyName else {
                        return Observable.just(Response.error(UnpauseError.emptyError))
                }
                return self.saveUserInfoOnServer(email: userEmail, firstName: userFirstName, lastName: userLastName)
                    .flatMapLatest ({ _ -> Observable<Response> in
                        return Observable.just(Response.success)
                    }).catchError ({ error -> Observable<Response> in
                        return Observable.just(Response.error(error))
                    })
        }
    }
    
    private func saveUserInfoOnServer(email: String, firstName: String, lastName: String) -> Observable<Void> {
        return self.dataBaseReference
            .collection("users")
            .document("\(email)")
            .rx
            .setData(["firstName": "\(firstName)",
                "lastName": "\(lastName)",
                "email": "\(email)"], merge: true)
    }
}
