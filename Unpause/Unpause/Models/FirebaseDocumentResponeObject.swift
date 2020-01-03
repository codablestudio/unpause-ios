//
//  FirebaseDocumentResponeObject.swift
//  Unpause
//
//  Created by Krešimir Baković on 03/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FirebaseDocumentResponseObject {
    case documentSnapshot(DocumentSnapshot)
    case error(Error)
}

