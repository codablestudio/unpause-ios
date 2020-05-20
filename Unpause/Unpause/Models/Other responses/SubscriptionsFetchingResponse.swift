//
//  SubscriptionsFetchingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase

enum SubscriptionsFetchingResponse {
    case success((Timestamp?, Timestamp?))
    case error(UnpauseError)
}
