//
//  CompanyFetchingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 04/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum CompanyFetchingResponse {
    case success(Company)
    case error(UnpauseError)
}
