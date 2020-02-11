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
    private let disposeBag = DisposeBag()
    
    func checkInUser(with time: Date) -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else { return Observable.empty() }
        
        var shiftsData = [String: Any]()
        
        let newShiftData = ["arrivalTime": Timestamp(date: time), "description": "", "exitTime": ""] as [String : Any]
        let newShiftDataFieldValue = FieldValue.arrayUnion([newShiftData])
        shiftsData["shifts"] = newShiftDataFieldValue
        
        return dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .updateData(shiftsData)
            .flatMapLatest({ _ -> Observable<Response> in
                return Observable.just(Response.success)
            })
            .catchError({ error -> Observable<Response> in
                return Observable.just(Response.error(error))
            })
    }
}
