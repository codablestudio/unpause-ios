//
//  Networking.swift
//  Unpause
//
//  Created by Krešimir Baković on 14/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Networking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func a() {
        dataBaseReference.collection("Kreso").addDocument(data: ["year" : 2019])
    }
    
}
