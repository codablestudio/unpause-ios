//
//  ActivityViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol ActivityViewModelProtocol {
    var shiftsRequest: Observable<[ShiftsTableViewItem]>! { get }
    var deleteRequest: Observable<ShiftDeletionResponse>! { get }
    
    var refreshTrigger: PublishSubject<Void> { get }
    var firstFilterDateChanges: PublishSubject<Date> { get }
    var secondFilterDateChanges: PublishSubject<Date> { get }
    var activityStarted: PublishSubject<Void> { get }
    var shiftToDelete: PublishSubject<Shift> { get }
    
    func makeNewCSVFileWithShiftsData(shiftsData: [ShiftsTableViewItem]) -> CSVMakingResponse
    func makeDataFrom(csvMakingResponse: CSVMakingResponse) -> DataMakingResponse
}
