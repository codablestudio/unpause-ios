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
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) -> Observable<FirebaseResponseObject> {
        return Observable.just(FirebaseResponseObject.error(.registrationError))
    }
    
    func signInGoogleUser(googleUser: GIDGoogleUser) -> Observable<GoogleUserSavingResponse> {
        return Observable.just(GoogleUserSavingResponse.error(.googleUserSignInError))
    }
    
    func saveUserInfoOnServer(email: String, firstName: String, lastName: String) -> Observable<Response> {
        return Observable.just(Response.error(UnpauseError.serverSavingError))
    }
}
