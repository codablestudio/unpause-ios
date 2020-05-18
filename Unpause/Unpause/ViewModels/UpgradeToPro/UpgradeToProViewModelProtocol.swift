//
//  UpgradeToProViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol UpgradeToProViewModelProtocol {
    var oneMonthSubscriptionSuccessfullyPurchased: PublishSubject<Void> { get }
    var oneYearSubscriptionSuccessfullyPurchased: PublishSubject<Void> { get }
    
    var oneMonthSubscriptionSavingResponse: Observable<Response>! { get }
    var oneYearSubscriptionSavingResponse: Observable<Response>! { get }
}
