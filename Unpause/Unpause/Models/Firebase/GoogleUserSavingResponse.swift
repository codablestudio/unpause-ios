//
//  GoogleUserSavingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import GoogleSignIn

enum GoogleUserSavingResponse: Equatable {
    case success(GIDGoogleUser)
    case error(UnpauseError)
}
