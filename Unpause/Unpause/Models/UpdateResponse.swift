//
//  UpdateResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum UpdateResponse: Error {
    case success
    case error(Error)
}
