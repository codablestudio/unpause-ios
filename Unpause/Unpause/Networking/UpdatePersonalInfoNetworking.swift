//
//  UpdatePersonalInfoNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import RxFirebase
import FirebaseFirestore

class UpdatePersonalInfoNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func updateUserWith(newFirstName: String?, newLastName: String?) -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email,
            let newFirstName = newFirstName,
            let newLastName = newLastName,
            !newLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !newFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return Observable.just(Response.error(UnpauseError.emptyError))
        }
        
        let response = dataBaseReference
            .collection("users")
            .document(currentUserEmail)
            .rx
            .updateData([
                "firstName": newFirstName,
                "lastName": newLastName,
            ])
        
        return response
            .flatMapLatest { _ -> Observable<Response> in
                let userWithNewData = User(firstName: newFirstName, lastName: newLastName, email: currentUserEmail)
                userWithNewData.company = SessionManager.shared.currentUser?.company
                SessionManager.shared.logIn(userWithNewData)
                return Observable.just(Response.success)
        }
        .catchError { (error) -> Observable<Response> in
            return Observable.just(Response.error(error))
        }
    }
}
