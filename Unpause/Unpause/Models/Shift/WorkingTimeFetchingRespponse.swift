//
//  WorkingTimeFetchingRespponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 28/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum WorkingTimeFetchingRespponse {
    case succes([Double])
    case error(UnpauseError)
}
