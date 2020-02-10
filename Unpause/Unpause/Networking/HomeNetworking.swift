//
//  HomeNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import RxSwift
import RxFirebase

class HomeNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func checkInUser(with time: Date) {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return
        }
        print("PZIVVVVVVVVVV")
        dataBaseReference.collection("users")
            .document("\(currentUserEmail)")
            .updateData(["shifts":
            
            ["arrivalTime": "676367670",
                "description": "",
                "exitTime": ""]
                
        ])
    }
}
