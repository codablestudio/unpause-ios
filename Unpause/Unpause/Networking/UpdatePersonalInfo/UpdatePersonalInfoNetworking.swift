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

class UpdatePersonalInfoNetworking: UpdatePersonalInfoNetworkingProtocol {
    
    private let dataBaseReference = Firestore.firestore()
    
    func updateUserWith(newFirstName: String?, newLastName: String?) -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email,
            let newFirstName = newFirstName,
            let newLastName = newLastName,
            !newLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !newFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return Observable.just(Response.error(.emptyTextFieldError))
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
            .flatMapLatest { [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                guard let currentUser = SessionManager.shared.currentUser else {
                    return Observable.just(Response.error(.userCreatingError))
                }
                self.changeCurrentUserFirstNameAndLastName(newFirstName: newFirstName, newLastName: newLastName)
                SessionManager.shared.logIn(currentUser)
                return Observable.just(Response.success)
        }
        .catchError { error -> Observable<Response> in
            return Observable.just(Response.error(.otherError(error)))
        }
    }
    
    private func changeCurrentUserFirstNameAndLastName(newFirstName: String, newLastName: String) {
        SessionManager.shared.currentUser?.firstName = newFirstName
        SessionManager.shared.currentUser?.lastName = newLastName
    }
}
