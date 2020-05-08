//
//  DocumentIDFetchingResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 09/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase

enum DocumentReferenceFetchingResponse {
    case success(DocumentReference?)
    case error(UnpauseError)
}
