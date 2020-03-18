//
//  CompanyValidationData.swift
//  Unpause
//
//  Created by Krešimir Baković on 09/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

class CompanyValidationData {
    var companyName: String?
    var companyPassCode: String?
    var companyReference: String?
    
    init(companyName: String?, companyPassCode: String?, companyReference: String?) {
        self.companyName = companyName
        self.companyPassCode = companyPassCode
        self.companyReference = companyReference
    }
}
