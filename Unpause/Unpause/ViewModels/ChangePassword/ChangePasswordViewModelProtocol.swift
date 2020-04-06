//
//  ChangePasswordViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol ChangePasswordViewModelProtocol {
    var textInCurrentPasswordTextFieldChanges: PublishSubject<String?> { get }
    var textInNewPasswordTextFieldChanges: PublishSubject<String?> { get }
    var changePasswordButtonTapped: PublishSubject<Void> { get }
    
    var changePasswordResponse: Observable<Response>! { get }
}
