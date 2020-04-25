//
//  LoginViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import GoogleSignIn

protocol LoginViewModelProtocol {
    var textInEmailTextFieldChanges: PublishSubject<String?> { get }
    var textInPasswordTextFieldChanges: PublishSubject<String?> { get }
    var logInButtonTapped: PublishSubject<Void>{ get }
    var registerNowButtonTapped: PublishSubject<Void> { get }
    var googleUserSignInResponse: PublishSubject<GIDGoogleUser> { get }
    
    var loginRequest: Observable<FirebaseResponseObject>! { get }
    var loginDocument: Observable<UnpauseResponse>! { get }
    var googleUserSavingResponse: Observable<UnpauseResponse>! { get }
    var isInsideGoogleSignInFlow: Observable<Bool>! { get }
}
