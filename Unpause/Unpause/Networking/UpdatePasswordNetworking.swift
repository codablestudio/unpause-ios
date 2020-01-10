//
//  UpdatePasswordNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore
import FirebaseAuth

class UpdatePasswordNetworking {
    
    private let dataBaseReference = Auth.auth()
    
    func updateCurrentUserPassword(with oldPassword: String?,with newPassword: String?) -> Observable<UpdateResponse> {
        guard let email = SessionManager.shared.currentUser?.email,
            let oldPassword = oldPassword,
            let newPassword = newPassword,
            let user = dataBaseReference.currentUser,
            !oldPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return Observable.empty()
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        
        return user.rx.reauthenticateAndRetrieveData(with: credential)
            .flatMapLatest { _ -> Observable<Void> in
                return user.rx.updatePassword(to: newPassword)
        }
        .flatMapLatest { _ -> Observable<UpdateResponse> in
            return Observable.just(UpdateResponse.success)
        }.catchError { (error) -> Observable<UpdateResponse> in
            return Observable.just(UpdateResponse.error(error))
        }
    }
}
