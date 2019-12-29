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

class RegisterNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) -> Observable<FirebaseResponseObject> {
        Auth.auth().rx.createUser(withEmail: email, password: password)
            .flatMapLatest { [weak self] (authDataResult) -> Observable<FirebaseResponseObject> in
                if authDataResult.user.email != nil {
                    self?.dataBaseReference.collection("users")
                    .document("\(email)")
                    .setData(["firstName": "\(firstName)",
                        "lastName": "\(lastName)"])
                    return Observable.just(FirebaseResponseObject.authDataResult(authDataResult))
                } else {
                    return Observable.just(FirebaseResponseObject.error(UnpauseError.defaultError))
                }
        }
        .catchError { (error) -> Observable<FirebaseResponseObject> in
            return Observable.just(FirebaseResponseObject.error(error))
        }
    }
}
