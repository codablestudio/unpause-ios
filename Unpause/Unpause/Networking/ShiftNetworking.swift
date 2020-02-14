//
//  ShiftNetworking.swift
//  Unpause
//
//  Created by Krešimir Baković on 12/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift

class ShiftNetworking {
    
    private let dataBaseReference = Firestore.firestore()
    
    func saveNewShift(arrivalTime: Timestamp?, leavingTime: Timestamp?, description: String?) -> Observable<Response> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email,
            let arrivalTime = arrivalTime,
            let leavingTime = leavingTime,
            let description = description else {
                return Observable.just(Response.error(UnpauseError.emptyError))
        }
        
        
        return fetchShifts()
            .map({ shiftsResponse -> [Shift] in
                switch shiftsResponse {
                case .success(let shifts):
                    return shifts
                default:
                    return []
                }
            })
            .map({ shifts -> ([Shift], Shift?) in
                return (shifts, shifts.last(where: { $0.exitTime == nil }))
            })
            .flatMapLatest({ (shifts, lastShiftWithOutExitTime) -> Observable<[Shift]> in
                let lastShiftWithNewExitTime = Shift()
                
                lastShiftWithNewExitTime.arrivalTime = arrivalTime
                lastShiftWithNewExitTime.exitTime = leavingTime
                lastShiftWithNewExitTime.description = description
                
                var newShiftArray = [Shift]()
                newShiftArray = shifts.dropLast()
                newShiftArray.append(lastShiftWithNewExitTime)
                
                return Observable.just(newShiftArray)
            })
            .flatMapLatest ({ [weak self] (newShiftArray) -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                
                let shiftsData = ShiftFactory().createShiftsData(from: newShiftArray)
                
                return self.dataBaseReference
                    .collection("users")
                    .document("\(currentUserEmail)")
                    .rx
                    .updateData(["shifts": shiftsData])
                    .flatMapLatest({ _ -> Observable<Response> in
                        return Observable.just(Response.success)
                    })
                    .catchError({ error -> Observable<Response> in
                        return Observable.just(Response.error(error))
                    })
            })
    }
    
    func fetchShifts() -> Observable<ShiftsResponse> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(.error(UnpauseError.noUser))
        }
        
        return dataBaseReference.collection("users")
            .document("\(currentUserEmail)").rx.getDocument()
            .mapShifts()
            .map({ shifts -> ShiftsResponse in
                return .success(shifts)
            })
            .catchError({ err -> Observable<ShiftsResponse> in
                return Observable.just(ShiftsResponse.error(err))
            })
    }
}
