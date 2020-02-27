//
//  CSVMakingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 25/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum CSVMakingResponse {
    case success(URL)
    case error(Error)
}
