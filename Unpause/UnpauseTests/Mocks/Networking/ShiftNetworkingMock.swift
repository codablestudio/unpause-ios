//
//  ShiftNetworkingMock.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 07/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import Foundation
import RxSwift
import Firebase

class ShiftNetworkingMock: ShiftNetworkingProtocol {
    func removeShiftWithOutExitTimeAndSaveNewShift(newShiftWithExitTime: Shift) -> Observable<Response> {
        return Observable.just(Response.error(UnpauseError.defaultError))
    }
    
    func saveNewShift(newShift: Shift) -> Observable<Response> {
        return Observable.just(Response.error(UnpauseError.defaultError))
    }
    
    func fetchShifts() -> Observable<ShiftsResponse> {
        return Observable.just(ShiftsResponse.error(UnpauseError.defaultError))
    }
    
    func filterShifts(fromDate: Date, toDate: Date, allShifts: ShiftsResponse) -> Observable<ShiftsResponse> {
        return Observable.just(ShiftsResponse.error(UnpauseError.defaultError))
    }
    
    func deleteShift(shiftToDelete: Shift) -> Observable<ShiftDeletionResponse> {
        return Observable.just(ShiftDeletionResponse.error(UnpauseError.defaultError))
    }
    
    func removeShiftFromShiftsArray(shiftToRemove: Shift, shifts: [Shift]) -> [Shift] {
        return []
    }
    
    func saveNewShiftsArrayOnServer(newShiftArray: [Shift]) -> Observable<Void> {
        return Observable.just(())
    }
}
