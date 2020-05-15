//
//  UpgradeToProViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift
import StoreKit

class UpgradeToProViewModel: UpgradeToProViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    
    var oneMonthSubscriptionSuccessfullyPurchased = PublishSubject<Void>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        oneMonthSubscriptionSuccessfullyPurchased.subscribe(onNext: { _ in
            
        }).disposed(by: disposeBag)
    }
}
