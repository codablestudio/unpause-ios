//
//  DescriptionViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol DescriptionViewModelProtocol {
    var textInEmailTextFieldChanges: PublishSubject<String?> { get }
    var saveButtonTapped: PublishSubject<Void> { get }
    var saveButtonFromTableViewTapped: PublishSubject<Void> { get }
    
    var shiftSavingResponse: Observable<Response>! { get }
    var shiftEditingResponse: Observable<Response>! { get }
}
