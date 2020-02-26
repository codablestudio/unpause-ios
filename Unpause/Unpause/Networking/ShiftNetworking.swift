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
    
    func removeShiftWithOutExitTimeAndSaveNewShift(newShiftWithExitTime: Shift) -> Observable<Response> {
        return fetchShifts()
            .map({ shiftsResponse -> ([Shift], Shift) in
                switch shiftsResponse {
                case .success(let shifts):
                    return (shifts, newShiftWithExitTime)
                default:
                    return ([],Shift())
                }
            })
            .map({ [weak self] (shifts, newShiftWithExitTime) -> ([Shift], Shift?, Shift) in
                return (shifts, self?.findShiftWithOutExitTime(shifts: shifts), newShiftWithExitTime)
            })
            .flatMapLatest({ [weak self] (shifts, shiftWithOutExitTime, newShiftWithExitTime) -> Observable<[Shift]> in
                guard let `self` = self,
                    let shiftWithoutExitTime = shiftWithOutExitTime else {
                        return Observable.just([])
                }
                
                return self.popShiftWithOutExitTimeAndAddShiftWithExitTime(shifts: shifts,
                                                                           shiftWithOutExitTime: shiftWithoutExitTime,
                                                                           newShiftWithExitTime: newShiftWithExitTime)
            })
            .flatMapLatest ({ [weak self] (newShiftArray) -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                
                return self.saveNewShiftsArrayOnServer(newShiftArray: newShiftArray)
                    .flatMapLatest({ _ -> Observable<Response> in
                        return Observable.just(Response.success)
                    })
                    .catchError({ error -> Observable<Response> in
                        return Observable.just(Response.error(error))
                    })
            })
    }
    
    func saveNewShift(newShift: Shift) -> Observable<Response> {
        return fetchShifts()
            .map({ shiftsResponse -> ([Shift], Shift) in
                switch shiftsResponse {
                case .success(let shifts):
                    return (shifts, newShift)
                default:
                    return ([],Shift())
                }
            })
            .map({ [weak self] (shifts, newShift) ->  [Shift] in
                guard let `self` = self else { return [] }
                return self.addShiftOnRightPlaceInShiftArray(shifts: shifts, newShift: newShift)
            })
            .flatMapLatest ({ [weak self] (newShiftArray) -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                
                return self.saveNewShiftsArrayOnServer(newShiftArray: newShiftArray)
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
            .document("\(currentUserEmail)")
            .rx
            .getDocument()
            .mapShifts()
            .map({ shifts -> ShiftsResponse in
                return .success(shifts)
            })
            .catchError({ err -> Observable<ShiftsResponse> in
                return Observable.just(ShiftsResponse.error(err))
            })
    }
    
    func filterShifts(fromDate: Date, toDate: Date, allShifts: ShiftsResponse) -> Observable<ShiftsResponse> {
        switch allShifts {
        case .success(let allShifts):
            var filteredArrayOfShifts = [Shift]()
            for shift in allShifts {
                guard let arrivalDateInDateFormat =
                    Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.arrivalTime) else {
                        return Observable.just(ShiftsResponse.error(UnpauseError.emptyError))
                }
                
                if arrivalDateInDateFormat >= fromDate && arrivalDateInDateFormat <= toDate && shift.exitTime != nil {
                    filteredArrayOfShifts.append(shift)
                }
            }
            return Observable.just(ShiftsResponse.success(filteredArrayOfShifts.reversed()))
        case .error(let error):
            print("Error")
            return Observable.just(ShiftsResponse.error(error))
        }
    }
    
    func deleteShift(shiftToDelete: Shift) -> Observable<ShiftDeletionResponse> {
        return fetchShifts()
            .flatMapLatest { [weak self] shiftsResponse -> Observable<ShiftDeletionResponse> in
                guard let `self` = self else { return Observable.empty() }
                switch shiftsResponse {
                case .success(let shifts):
                    let newShiftArray = self.getNewArrayOfShiftsWithOutOneShift(shifts: shifts,
                                                                                shiftToRemove: shiftToDelete)
                    
                    return self.saveNewShiftsArrayOnServerAndReturnDeletedShift(newShiftArray: newShiftArray,
                                                                                shiftToDelete: shiftToDelete)
                case .error(let error):
                    return Observable.just(ShiftDeletionResponse.error(error))
                }
        }
    }
    
    func removeShiftFromShiftsArray(shiftToRemove: Shift, shifts: [Shift]) -> [Shift] {
        var newArray = [Shift]()
        for shift in shifts {
            if shift != shiftToRemove {
                newArray.append(shift)
            }
        }
        return newArray
    }
    
    func saveNewShiftsArrayOnServer(newShiftArray: [Shift]) -> Observable<Void> {
        guard let currentUserEmail = SessionManager.shared.currentUser?.email else {
            return Observable.just(())
        }
        
        let shiftsData = ShiftFactory().createShiftsData(from: newShiftArray)
        
        return self.dataBaseReference
            .collection("users")
            .document("\(currentUserEmail)")
            .rx
            .updateData(["shifts": shiftsData])
    }
    
    private func saveNewShiftsArrayOnServerAndReturnDeletedShift(newShiftArray: [Shift], shiftToDelete: Shift) -> Observable<ShiftDeletionResponse> {
        return saveNewShiftsArrayOnServer(newShiftArray: newShiftArray)
            .flatMapLatest({ _ -> Observable<ShiftDeletionResponse> in
                return Observable.just(ShiftDeletionResponse.success(shiftToDelete))
            })
            .catchError({ error -> Observable<ShiftDeletionResponse> in
                return Observable.just(ShiftDeletionResponse.error(error))
            })
    }
    
    private func getNewArrayOfShiftsWithOutOneShift(shifts: [Shift], shiftToRemove: Shift) -> [Shift] {
        var newShiftArray = [Shift]()
        for shift in shifts {
            if shift != shiftToRemove {
                newShiftArray.append(shift)
            }
        }
        return newShiftArray
    }
    
    private func popShiftWithOutExitTimeAndAddShiftWithExitTime(shifts: [Shift],
                                                                shiftWithOutExitTime: Shift,
                                                                newShiftWithExitTime: Shift) -> Observable<[Shift]> {
        
        var newShiftArray = [Shift]()
        for shift in shifts {
            if shift == shiftWithOutExitTime {
                newShiftArray.append(newShiftWithExitTime)
            } else {
                newShiftArray.append(shift)
            }
        }
        
        return Observable.just(newShiftArray)
    }
    
    private func addShiftOnRightPlaceInShiftArray(shifts: [Shift], newShift: Shift) -> [Shift] {
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
    
    private func findShiftWithOutExitTime(shifts: [Shift]) -> Shift {
        var shiftWithOutExitTime = Shift()
        for shift in shifts {
            if shift.exitTime == nil {
                shiftWithOutExitTime = shift
            }
        }
        return shiftWithOutExitTime
    }
}
