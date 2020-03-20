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
    
    static func createShift(from shiftData: [String: Any]) -> Shift? {
        guard let arrivalTimestamp = shiftData["arrivalTime"] as? Timestamp else { return nil }
        let newShift = Shift()
        newShift.arrivalTime = arrivalTimestamp
        newShift.exitTime = shiftData["exitTime"] as? Timestamp
        newShift.description = shiftData["description"] as? String
        return newShift
    }
    
    static func createShifts(_ data: [String: Any]) -> [Shift] {
        var shifts = [Shift]()
        let shiftsData = data["shifts"] as? [[String: Any]] ?? []
        
        for shiftData in shiftsData {
            if let newShift = ShiftFactory.createShift(from: shiftData) {
                shifts.append(newShift)
            }
        }
        return shifts
    }
    
    static func createShiftData(from shift: Shift) -> [String: Any] {
        var newShiftData = [String: Any]()
        newShiftData["arrivalTime"] = shift.arrivalTime
        newShiftData["exitTime"] = shift.exitTime
        newShiftData["description"] = shift.description
        return newShiftData
    }
    
    static func createShiftsData(from shifts: [Shift]) -> [[String: Any]] {
        var shiftsData = [[String: Any]]()
        for shift in shifts {
            let newShiftData = ShiftFactory.createShiftData(from: shift)
            shiftsData.append(newShiftData)
        }
        return shiftsData
    }
    
    static func addShiftOnRightPlaceInShiftArray(shifts: [Shift], newShift: Shift) -> [Shift] {
        var newShiftArray = [Shift]()
        var shiftInserted = false
        for shift in shifts {
            guard let shiftArrivalDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.arrivalTime),
                let newShiftArrivalDateAndTime = Formatter.shared.convertTimeStampIntoDate(timeStamp: newShift.arrivalTime) else {
                    return []
            }
            
            if newShiftArrivalDateAndTime < shiftArrivalDateAndTime && !shiftInserted {
                newShiftArray.append(newShift)
                newShiftArray.append(shift)
                shiftInserted = true
            } else {
                newShiftArray.append(shift)
            }
        }
        
        if !shiftInserted {
            newShiftArray.append(newShift)
        }
        return newShiftArray
    }
}
