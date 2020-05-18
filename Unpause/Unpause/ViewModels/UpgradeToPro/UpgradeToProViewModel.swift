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
    private let inAppPurchaseNetworking: InAppPurchaseNetworkingProtocol
    
    var oneMonthSubscriptionSavingResponse: Observable<Response>!
    var oneYearSubscriptionSavingResponse: Observable<Response>!
    
    var oneMonthSubscriptionSuccessfullyPurchased = PublishSubject<Void>()
    var oneYearSubscriptionSuccessfullyPurchased = PublishSubject<Void>()
    
    init(inAppPurchaseNetworking: InAppPurchaseNetworkingProtocol) {
        self.inAppPurchaseNetworking = inAppPurchaseNetworking
        setUpObservables()
    }
    
    private func setUpObservables() {
        oneMonthSubscriptionSavingResponse = oneMonthSubscriptionSuccessfullyPurchased
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                return self.inAppPurchaseNetworking.saveUserOneMonthSubscriptionDateInDatabase()
            })
        
        oneYearSubscriptionSavingResponse = oneYearSubscriptionSuccessfullyPurchased
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                return self.inAppPurchaseNetworking.saveUserOneYearSubscriptionDateInDatabase()
            })
    }
}
