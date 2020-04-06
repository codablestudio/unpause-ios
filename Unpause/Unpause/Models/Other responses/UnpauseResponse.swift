//
//  UnpauseResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum UnpauseResponse: Equatable {
    case success
    case error(UnpauseError)
}
