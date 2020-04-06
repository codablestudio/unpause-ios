//
//  ForgotPasswordViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol ForgotPasswordViewModelProtocol {
    var textInEmailTextFieldChanges: PublishSubject<String?> { get }
    var sendRecoveryEmailButtonTapped: PublishSubject<Void> { get }
    
    var recoveryMailSendingResponse: Observable<Response>! { get }
}
