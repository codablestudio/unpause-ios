//
//  UpdatePersonalInfoViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol UpdatePersonalInfoViewModelProtocol {
    var textInNewFirstNameTextFieldChanges: PublishSubject<String?> { get }
    var textInNewLastNameTextFieldChanges: PublishSubject<String?> { get }
    var updateInfoButtonTapped: PublishSubject<Void> { get }
    
    var updateInfoResponse: Observable<Response>! { get }
}
