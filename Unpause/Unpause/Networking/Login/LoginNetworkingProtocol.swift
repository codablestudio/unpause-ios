//
//  LoginNetworkingProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol LoginNetworkingProtocol {
    func signInUserWith(email: String, password: String) -> Observable<FirebaseResponseObject>
    func getInfoFromUserWith(firebaseResponseObject: FirebaseResponseObject) -> Observable<FirebaseDocumentResponseObject>
    func sendPasswordResetTo(email: String) -> Observable<Response>
}
