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
    
    func signInUserWith(email: String, password: String) -> Observable<FirebaseResponseObject> {
        Auth.auth().rx.signIn(withEmail: email, password: password)
            .flatMapLatest({ authDataResult -> Observable<FirebaseResponseObject> in
                if email == authDataResult.user.email {
//                    let a = self?.dataBaseReference.collection("users").document(email).rx.getDocument().do(onNext: { (document) in
//                        print("AAAAA: \(document.data())")
//                    })
//                    print("Ovo je mali a:\(a)")
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
