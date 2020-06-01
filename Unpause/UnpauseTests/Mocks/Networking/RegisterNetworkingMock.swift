//
//  RegisterNetworkingMock.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn

class RegisterNetworkingMock: RegisterNetworkingProtocol {
    func signInGoogleUser(googleUser: GIDGoogleUser) -> Observable<FirebaseResponseObject> {
        return Observable.just(FirebaseResponseObject.error(.defaultError))
    }
    
    func checkIfUserIsAlreadyInDatabase(email: String) -> Observable<GoogleUserResponse> {
        return Observable.just(GoogleUserResponse.error(.defaultError))
    }
    
    func saveUserOnServerAndReturnUserDocument(email: String, firstName: String, lastName: String) -> Observable<FirebaseDocumentResponseObject> {
        return Observable.just(FirebaseDocumentResponseObject.error(.defaultError))
    }
    
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) -> Observable<FirebaseResponseObject> {
        return Observable.just(FirebaseResponseObject.error(.registrationError))
    }
    
    func saveUserInfoOnServer(email: String, firstName: String, lastName: String) -> Observable<Response> {
        return Observable.just(Response.error(UnpauseError.serverSavingError))
    }
    
    func checkIfUserIsAlreadyInDatabase(email: String) -> Observable<FirebaseDocumentResponseObject> {
        return Observable.just(FirebaseDocumentResponseObject.error(.defaultError))
    }
    func signnInGoogleUser(googleUser: GIDGoogleUser) -> Observable<FirebaseResponseObject> {
        return Observable.just(FirebaseResponseObject.error(.defaultError))
    }
}
