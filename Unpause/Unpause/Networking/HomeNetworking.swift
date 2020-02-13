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
    
    func getUsersLastCheckInTime() -> Observable<LastCheckInResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(.error(UnpauseError.noUser))
        }
        
        return dataBaseReference.collection("users")
            .document("\(currentUserEmail)")
            .rx
            .getDocument()
            .mapShifts()
            .map({ shifts -> Shift? in
                return shifts.last(where: { $0.exitTime == nil })
            })
            .flatMapLatest({ lastShiftWithoutExitTime -> Observable<LastCheckInResponse> in
                let lastArrivalDateAndTime = Formatter
                    .shared
                    .convertTimeStampIntoDate(timeStamp: lastShiftWithoutExitTime?.arrivalTime)
                return Observable.just(LastCheckInResponse.lastCheckIn(lastArrivalDateAndTime))
            })
    }
    
    func checkInUser(with time: Date) -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(.error(UnpauseError.noUser))
        }
        
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
