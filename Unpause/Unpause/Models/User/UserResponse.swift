//
//  UserResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 05/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum UserResponse {
    case success(User)
    case error(UnpauseError)
}
