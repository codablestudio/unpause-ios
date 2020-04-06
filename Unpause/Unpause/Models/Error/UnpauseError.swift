//
//  UnpauseError.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation

enum UnpauseError: Error, Equatable {
    static func == (lhs: UnpauseError, rhs: UnpauseError) -> Bool {
        return lhs.errorMessage == rhs.errorMessage
    }
    
    case defaultError
    case wrongUserData
    case emptyError
    case noUser
    case noCompany
    case serverSavingError
    case fetchingCompanyReferenceError
    case companyMakingError
    case fetchingUserInfoError
    case userCreatingError
    case companyFetchingError
    case registrationError
    case googleUserSignInError
    case otherError(Error)
    
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
        case .serverSavingError:
            return "Data is not successfully saved on server."
        case .fetchingCompanyReferenceError:
            return "Unable to fetch compnay reference from server."
        case .companyMakingError:
            return "Could not make company from given data."
        case .fetchingUserInfoError:
            return "Could not fetch user ifo from server."
        case .userCreatingError:
            return "Unable to create user."
        case .companyFetchingError:
            return "Unable to fetch company."
        case .registrationError:
            return "Unable to register user. Reason: unknown."
        case .googleUserSignInError:
            return "Google user sign in error. Please try again."
        case .otherError(let error):
            return "\(error.localizedDescription)"
        }
    }
}
