//
//  ShitfsResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 13/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseAuth

enum ShiftsResponse {
    case success([Shift])
    case error(Error)
}
