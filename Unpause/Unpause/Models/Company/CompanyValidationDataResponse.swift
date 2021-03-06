//
//  CompanyValidationDataResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 09/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum CompanyValidationDataResponse {
    case success(CompanyValidationData)
    case error(Error)
}
