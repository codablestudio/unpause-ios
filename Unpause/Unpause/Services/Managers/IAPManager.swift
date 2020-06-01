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
    private let appleValidator: AppleReceiptValidator!
    
    let oneMonthSubscriptionProductID = "studio.codable.unpause.CSVAndLocationAutoPurchase"
    let oneYearSubscriptionProductID = "studio.codable.unpause.CSVAndLocationOneYearPurchase"
    let sharedSecret = "616c6c6ee2f3499197f22fd9be1b5af5"
    
    static var shared = IAPManager()
    
    private init() {
        appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedSecret)
    }
    
    func updateUserSubscriptionStatus(onCompleted: @escaping () -> Void) {
        updateOneMonthAutoRenewingSubscriptionValidationDate(onCompleted: {
            self.updateOneYearAutoRenewingSubscriptionValidationDate(onCompleted: {
                onCompleted()
            })
        })
    }
    
    private func updateOneMonthAutoRenewingSubscriptionValidationDate(onCompleted: @escaping () -> Void) {
        SwiftyStoreKit.verifyReceipt(using: self.appleValidator) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let receipt):
                let productId = self.oneMonthSubscriptionProductID
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable,
                                                                       productId: productId,
                                                                       inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, _), .expired(let expiryDate, _):
                    SessionManager.shared.currentUser?.monthSubscriptionEndingDate = expiryDate
                case .notPurchased:
                    SessionManager.shared.currentUser?.monthSubscriptionEndingDate = nil
                }
                onCompleted()
            case .error(let error):
                print("Receipt verification failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateOneYearAutoRenewingSubscriptionValidationDate(onCompleted: @escaping () -> Void) {
        SwiftyStoreKit.verifyReceipt(using: self.appleValidator) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let receipt):
                let productId = self.oneYearSubscriptionProductID
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable,
                                                                       productId: productId,
                                                                       inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, _), .expired(let expiryDate, _):
                    SessionManager.shared.currentUser?.yearSubscriptionEndingDate = expiryDate
                case .notPurchased:
                    SessionManager.shared.currentUser?.yearSubscriptionEndingDate = nil
                }
                onCompleted()
            case .error(let error):
                print("Receipt verification failed: \(error.localizedDescription)")
            }
        }
    }
}
