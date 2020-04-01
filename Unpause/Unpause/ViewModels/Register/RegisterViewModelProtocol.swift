//
//  RegisterViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol RegisterViewModelProtocol {
    var textInFirstNameTextFieldChanges: PublishSubject<String?> { get }
    var textInLastNameTextFieldChanges : PublishSubject<String?> { get }
    var textInEmailTextFieldChanges : PublishSubject<String?> { get }
    var textInNewPasswordTextFieldChanges : PublishSubject<String?> { get }
    var registerButtonTapped : PublishSubject<Void> { get }
    
    var registerResponse: Observable<FirebaseResponseObject>! { get }
}
