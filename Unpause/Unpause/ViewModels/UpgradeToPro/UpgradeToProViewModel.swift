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
    
    init(inAppPurchaseNetworking: InAppPurchaseNetworkingProtocol) {
        self.inAppPurchaseNetworking = inAppPurchaseNetworking
        setUpObservables()
    }
    
    private func setUpObservables() {
        
    }
}
