//
//  ShiftFactory.swift
//  Unpause
//
//  Created by Krešimir Baković on 12/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import RxSwift
import FirebaseFirestore

class ShiftFactory {
    
    func createShifts(_ data: [String: Any]) -> [Shift] {
        var shifts = [Shift]()
        let shiftsData = data["shifts"] as? [[String: Any]] ?? []
        
        for shiftData in shiftsData {
            if let newShift = createShift(from: shiftData) {
                shifts.append(newShift)
            }
        }
        return shifts
    }
    
    func createShift(from shiftData: [String: Any]) -> Shift? {
        guard let arrivalTimestamp = shiftData["arrivalTime"] as? Timestamp else { return nil }
        let newShift = Shift()
        newShift.arrivalTime = arrivalTimestamp
        newShift.exitTime = shiftData["exitTime"] as? Timestamp
        newShift.description = shiftData["description"] as? String
        return newShift
    }
}

extension ObservableType where Element == DocumentSnapshot {
    func mapShifts() -> Observable<[Shift]> {
        return map({ document -> [Shift] in
            if let data = document.data() {
                return ShiftFactory().createShifts(data)
            }
            return []
        })
    }
}
