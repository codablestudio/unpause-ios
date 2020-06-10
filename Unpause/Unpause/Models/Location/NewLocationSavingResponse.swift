//
//  NewLocationSavingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum NewLocationSavingResponse {
    case success(String)
    case error(UnpauseError)
}
