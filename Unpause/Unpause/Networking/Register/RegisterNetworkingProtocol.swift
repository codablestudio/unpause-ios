//
//  RegisterNetworkingProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn

protocol RegisterNetworkingProtocol {
    func registerUserWith(firstName: String, lastName: String, email: String, password: String) -> Observable<FirebaseResponseObject>
    func signInGoogleUser(googleUser: GIDGoogleUser) -> Observable<GoogleUserSavingResponse>
    func saveUserInfoOnServer(email: String, firstName: String, lastName: String) -> Observable<Response>
}
