//
//  FirebaseResponseObject.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseAuth

enum FirebaseResponseObject {
    case success(AuthDataResult)
    case error(UnpauseError)
}
