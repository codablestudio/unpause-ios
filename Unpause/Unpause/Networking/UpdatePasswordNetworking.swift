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
    
    func updateCurrentUserPassword(with oldPassword: String?,with newPassword: String?) -> Observable<UpdatePasswordResponse> {
        guard let email = SessionManager.shared.currentUser?.email,
            let oldPassword = oldPassword,
            let newPassword = newPassword,
            let user = dataBaseReference.currentUser else {
                return Observable.error(UnpauseError.defaultError)
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        
        return user.rx.reauthenticateAndRetrieveData(with: credential)
            .flatMapLatest { _ -> Observable<Void> in
                return user.rx.updatePassword(to: newPassword)
        }
        .flatMapLatest { _ -> Observable<UpdatePasswordResponse> in
            return Observable.just(UpdatePasswordResponse.success)
        }.catchError { (error) -> Observable<UpdatePasswordResponse> in
            return Observable.just(UpdatePasswordResponse.error(error))
        }
    }
}
