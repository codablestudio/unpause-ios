//
//  AddCompanyViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol AddCompanyViewModelProtocol {
    var textInCompanyPassCodeTextFieldChanges: PublishSubject<String?> { get }
    var addCompanyButtonTapped: PublishSubject<Void> { get }
    
    var companyAddingResponse: Observable<Response>! { get }
}
