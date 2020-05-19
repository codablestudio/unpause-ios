//
//  PurchaseResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import SwiftyStoreKit

enum PurchaseResponse {
    case success(VerifySubscriptionResult)
    case error(UnpauseError)
}
