//
//  DataMakingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 27/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum DataMakingResponse {
    case success(Data)
    case error(UnpauseError)
}
