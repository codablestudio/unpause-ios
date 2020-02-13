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
    
    func createShift(from shiftData: [String: Any]) -> Shift? {
        guard let arrivalTimestamp = shiftData["arrivalTime"] as? Timestamp else { return nil }
        let newShift = Shift()
        newShift.arrivalTime = arrivalTimestamp
        newShift.exitTime = shiftData["exitTime"] as? Timestamp
        newShift.description = shiftData["description"] as? String
        return newShift
    }
    
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
    
    func createShiftData(from shift: Shift) -> [String: Any] {
        var newShiftData = [String: Any]()
        newShiftData["arrivalTime"] = shift.arrivalTime
        newShiftData["exitTime"] = shift.exitTime
        newShiftData["description"] = shift.description
        return newShiftData
    }
    
    func createShiftsData(from shifts: [Shift]) -> [[String: Any]] {
        var shiftsData = [[String: Any]]()
        for shift in shifts {
            let newShiftData = createShiftData(from: shift)
            shiftsData.append(newShiftData)
        }
        return shiftsData
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
