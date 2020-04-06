//
//  LoginNetworkingMock.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class LoginNetworkingMock: LoginNetworkingProtocol {
    func signInUserWith(email: String, password: String) -> Observable<FirebaseResponseObject> {
        return Observable.just(FirebaseResponseObject.error(.wrongUserData))
    }
    
    func getInfoFromUserWith(firebaseResponseObject: FirebaseResponseObject) -> Observable<FirebaseDocumentResponseObject> {
        return Observable.just(FirebaseDocumentResponseObject.error(.defaultError))
    }
    
    func sendPasswordResetTo(email: String) -> Observable<Response> {
        return Observable.just(Response.error(UnpauseError.defaultError))
    }
}
