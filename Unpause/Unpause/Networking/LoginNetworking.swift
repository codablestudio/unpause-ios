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
                if let _ = authDataResult.user.email {
                    return Observable.just(FirebaseResponseObject.success(authDataResult))
                } else {
                    return Observable.just(FirebaseResponseObject.error(.wrongUserData))
                }
            })
            .catchError({ error -> Observable<FirebaseResponseObject> in
                return Observable.just(FirebaseResponseObject.error(.otherError(error)))
            })
    }
    
    func getInfoFromUserWith(firebaseResponseObject: FirebaseResponseObject) -> Observable<FirebaseDocumentResponseObject> {
        switch firebaseResponseObject {
        case .success(let authDataResult):
            guard let userEmail = authDataResult.user.email else {
                return Observable.just(FirebaseDocumentResponseObject.error(.noUser))
            }
            return dataBaseReference
                .collection("users")
                .document("\(userEmail)")
                .rx
                .getDocument()
                .flatMapLatest({ document -> Observable<FirebaseDocumentResponseObject> in
                    return Observable.just(FirebaseDocumentResponseObject.success(document))
                })
                .catchError { error -> Observable<FirebaseDocumentResponseObject> in
                    return Observable.just(FirebaseDocumentResponseObject.error(.otherError(error)))
            }
        case .error(let error):
            return Observable.just(FirebaseDocumentResponseObject.error(error))
        }
    }
    
    func sendPasswordResetTo(email: String) -> Observable<Response> {
        return Auth.auth().rx.sendPasswordReset(withEmail: email)
            .flatMapLatest { _ -> Observable<Response> in
                return Observable.just(Response.success)
        }
        .catchError ({ error -> Observable<Response> in
            return Observable.just(Response.error(error))
        })
    }
}
