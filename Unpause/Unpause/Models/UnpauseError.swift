//
//  UnpauseError.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation

indirect enum UnpauseError: Error, Equatable {
    static func == (lhs: UnpauseError, rhs: UnpauseError) -> Bool {
        return lhs.errorMessage == rhs.errorMessage
    }
    
    case defaultError
    case wrongUserData
    case emptyError
    case noUser
    case noCompany
    case otherError(Error)
    case unpauseError(UnpauseError)
    
    var errorMessage: String {
        switch self {
        case .defaultError:
            return "Default error."
        case .wrongUserData:
            return "Wrong username or password."
        case .emptyError:
            return "Empty error."
        case .noUser:
            return "No user."
        case .noCompany:
            return "There is no company associated with you."
        case .otherError(let error):
            return error.localizedDescription
        case .unpauseError(let error):
            return error.errorMessage
        }
    }
}
