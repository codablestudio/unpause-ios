//
//  Networking.swift
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

class Networking {
    
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
    
    // NA OVAJ NACIN SAM MISLIO IMPLEMENTIRATI SIGN IN ALI NISAM USPIO :/
    
//    func signInUserWith(email: String, password: String) -> Observable<String?> {
//        var returnedEmail: String?
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if error != nil {
//                print("Some error occurred \(error.debugDescription)")
//            } else {
//                print("User was successfully signed in.")
//                returnedEmail = authResult?.user.email
//            }
//        }
//        return Observable.just(returnedEmail)
//    }
}
