//
//  IAPManager.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import RxSwift

class IAPManager {
    
    let oneMonthSubscriptionProductID = "studio.codable.unpause.CSVAndLocationAutoPurchase"
    let oneYearSubscriptionProductID = "studio.codable.unpause.CSVAndLocationOneYearPurchase"
    let sharedSecret = "616c6c6ee2f3499197f22fd9be1b5af5"
    
    static var shared = IAPManager()
    
    private init() {}
    
    func checkAndSaveOneMonthAutoRenewingSubscriptionValidationDate() -> Completable {
        return Completable.create { [weak self] completable -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecret)
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let receipt):
                    let productId = self.oneMonthSubscriptionProductID
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let expiryDate, _):
                        SessionManager.shared.currentUser?.monthSubscriptionEndingDate = expiryDate
                    case .expired(let expiryDate, _):
                        SessionManager.shared.currentUser?.monthSubscriptionEndingDate = expiryDate
                    case .notPurchased:
                        SessionManager.shared.currentUser?.monthSubscriptionEndingDate = nil
                    }
                    completable(.completed)
                case .error(let error):
                    print("Receipt verification failed: \(error.localizedDescription)")
                    completable(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func checkAndSaveOneYearAutoRenewingSubscriptionValidationDate() -> Completable {
        return Completable.create { [weak self] completable -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecret)
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let receipt):
                    let productId = self.oneYearSubscriptionProductID
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased(let expiryDate, _):
                        SessionManager.shared.currentUser?.yearSubscriptionEndingDate = expiryDate
                    case .expired(let expiryDate, _):
                        SessionManager.shared.currentUser?.yearSubscriptionEndingDate = expiryDate
                    case .notPurchased:
                        SessionManager.shared.currentUser?.yearSubscriptionEndingDate = nil
                    }
                    completable(.completed)
                case .error(let error):
                    print("Receipt verification failed: \(error.localizedDescription)")
                    completable(.error(error))
                }
            }
            return Disposables.create()
        }
    }
}
