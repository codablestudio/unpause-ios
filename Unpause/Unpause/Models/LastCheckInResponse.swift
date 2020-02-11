//
//  LastCheckInResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 11/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum LastCheckInResponse: Error {
    case lastCheckIn(Date?)
    case error(Error)
}
