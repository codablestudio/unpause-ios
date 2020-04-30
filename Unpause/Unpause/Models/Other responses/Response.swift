//
//  UpdateResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum Response: Equatable {
    static func == (lhs: Response, rhs: Response) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    case success
    case error(UnpauseError)
}
