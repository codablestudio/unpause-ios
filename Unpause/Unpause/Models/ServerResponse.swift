//
//  ServerResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 17/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation


enum ServerResponse {
    case error(errorMessage: String)
    case success
}
