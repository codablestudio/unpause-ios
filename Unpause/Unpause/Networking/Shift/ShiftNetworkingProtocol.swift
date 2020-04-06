//
//  ShiftNetworkingProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol ShiftNetworkingProtocol {
    func removeShiftWithOutExitTimeAndSaveNewShift(newShiftWithExitTime: Shift) -> Observable<Response>
    func saveNewShift(newShift: Shift) -> Observable<Response>
    func fetchShifts() -> Observable<ShiftsResponse>
    func filterShifts(fromDate: Date, toDate: Date, allShifts: ShiftsResponse) -> Observable<ShiftsResponse>
    func deleteShift(shiftToDelete: Shift) -> Observable<ShiftDeletionResponse>
    func removeShiftFromShiftsArray(shiftToRemove: Shift, shifts: [Shift]) -> [Shift]
    func saveNewShiftsArrayOnServer(newShiftArray: [Shift]) -> Observable<Void>
}
