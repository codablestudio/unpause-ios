//
//  CompaniesFetchingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 07/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum CompaniesFetchingResponse {
    case success([Company])
    case error(Error)
}
