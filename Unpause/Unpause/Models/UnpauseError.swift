//
//  UnpauseError.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation

enum UnpauseError: Error {
    case defaultError
    case emptyError
    case noUser
    
    var errorMessage: String {
        switch self {
        case .defaultError:
            return "Default error"
        case .emptyError:
            return "Empty error"
        case .noUser:
            return "No user"
        }
    }
}
