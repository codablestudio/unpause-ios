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
    case emptyTextFieldError
    case noCompaniesError
    case wrongCompanyPasscodeError
    case noShiftsCSVError
    case dateConversionError
    case locationNameError
    case locationsFetchingError
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
        case .emptyTextFieldError:
            return "Please fill up all text fields that are mandatory."
        case .noCompaniesError:
            return "There are no companies to fetch."
        case .wrongCompanyPasscodeError:
            return "There is no commpany for that passcode. Please check your passcode and try again."
        case .noShiftsCSVError:
            return "Unable to make CSV file from empty table view list."
        case .dateConversionError:
            return "Unable to make conversion accros different date formats."
        case .locationNameError:
            return "Please add location name."
        case .locationsFetchingError:
            return "Locations fetching error."
        case .otherError(let error):
            return "\(error.localizedDescription)"
        }
    }
}
