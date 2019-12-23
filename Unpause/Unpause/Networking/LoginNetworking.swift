//
//  LoginNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 14/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import RxSwift
import RxFirebase

class LoginNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("Some error occurred \(error.debugDescription)")
            } else {
                print("User was successfully added.")
            }
        }
        dataBaseReference.collection("users")
            .document("\(email)")
            .setData(["firstName": "\(firstName)",
                "lastName": "\(lastName)"])
    }
    
    func signInUserWith(email: String, password: String) -> Observable<FirebaseResponseObject> {
        Auth.auth().rx.signIn(withEmail: email, password: password)
            .flatMapLatest({ authDataResult -> Observable<FirebaseResponseObject> in
                if let email = authDataResult.user.email {
                    print("logged in email: \(email)")
                    return Observable.just(FirebaseResponseObject.authDataResult(authDataResult))
                } else {
                    return Observable.just(FirebaseResponseObject.error(UnpauseError.defaultError))
                }
            })
            .catchError({ error -> Observable<FirebaseResponseObject> in
                return Observable.just(FirebaseResponseObject.error(error))
            })
    }
}
