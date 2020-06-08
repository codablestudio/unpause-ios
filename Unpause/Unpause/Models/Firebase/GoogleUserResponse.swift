//
//  GoogleUserResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 26/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum GoogleUserResponse {
    case existingUser(DocumentSnapshot)
    case notExistingUser
    case error(UnpauseError)
}
