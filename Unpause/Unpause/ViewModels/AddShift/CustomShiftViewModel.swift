//
//  CustomShiftViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol CustomShiftViewModelProtocol {
    func makeNewDateAndTimeWithCheckInDateAnd(timeInDateFormat: Date) -> Date?
    func makeNewDateAndTimeInDateFormat(dateInDateFormat: Date, timeInDateFormat: Date) -> Date?
    
    var saveButtonTapped:  PublishSubject<Void> { get }
    var textInDescriptionTextViewChanges:  PublishSubject<String?> { get }
    var arrivalDateAndTimeChanges:  PublishSubject<Date?> { get }
    var leavingDateAndTimeChanges:  PublishSubject<Date?> { get }
    
    var shiftSavingResponse: Observable<Response>! { get }
}

class CustomShiftViewModel: CustomShiftViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let shiftNetworking: ShiftNetworkingProtocol
    
    var saveButtonTapped = PublishSubject<Void>()
    var textInDescriptionTextViewChanges = PublishSubject<String?>()
    var arrivalDateAndTimeChanges = PublishSubject<Date?>()
    var leavingDateAndTimeChanges = PublishSubject<Date?>()
    
    var shiftSavingResponse: Observable<Response>!
    
    var textInDescriptionTextView: String?
    var arrivalDateAndTime: Date?
    var leavingDateAndTime: Date?
    
    init(shiftNetworking: ShiftNetworkingProtocol) {
        self.shiftNetworking = shiftNetworking
        setUpObservables()
    }
    
    func setUpObservables() {
        textInDescriptionTextViewChanges.subscribe(onNext: { [weak self] (descriptionText) in
            guard let `self` = self else { return }
            self.textInDescriptionTextView = descriptionText
        }).disposed(by: disposeBag)
        
        arrivalDateAndTimeChanges.subscribe(onNext: { [weak self] date in
            guard let `self` = self else { return }
            self.arrivalDateAndTime = date
        }).disposed(by: disposeBag)
        
        leavingDateAndTimeChanges.subscribe(onNext: { [weak self] date in
            guard let `self` = self else { return }
            self.leavingDateAndTime = date
        }).disposed(by: disposeBag)
        
        shiftSavingResponse = saveButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self,
                    let arrivalDateAndTime = self.arrivalDateAndTime,
                    let leavingDateAndTime = self.leavingDateAndTime else {
                        return Observable.just(Response.error(UnpauseError.emptyError))
                }
                
                if arrivalDateAndTime > leavingDateAndTime {
                    return Observable.just(Response.error(.wrongDateInputError))
                }
                
                let arrivalDateAndTimeInTimeStampFormat = Formatter.shared.convertDateIntoTimeStamp(date: arrivalDateAndTime)
                let leavingDateAndTimeInTimeStampFormat = Formatter.shared.convertDateIntoTimeStamp(date: leavingDateAndTime)
                
                let newShift = Shift()
                newShift.arrivalTime = arrivalDateAndTimeInTimeStampFormat
                newShift.exitTime = leavingDateAndTimeInTimeStampFormat
                newShift.description = self.textInDescriptionTextView
                
                return self.shiftNetworking.saveNewShift(newShift: newShift)
            })
    }
    
    func makeNewDateAndTimeWithCheckInDateAnd(timeInDateFormat: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        guard let lastCheckInDateAndTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime else {
            return Date()
        }
        
        let year = calendar.component(.year, from: lastCheckInDateAndTime)
        let month = calendar.component(.month, from: lastCheckInDateAndTime)
        let day = calendar.component(.day, from: lastCheckInDateAndTime)
        let hour = calendar.component(.hour, from: timeInDateFormat)
        let minute = calendar.component(.minute, from: timeInDateFormat)
        let second = calendar.component(.second, from: timeInDateFormat)
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        let newDateAndTime = calendar.date(from: dateComponents)
        return newDateAndTime
    }
    
    func makeNewDateAndTimeInDateFormat(dateInDateFormat: Date, timeInDateFormat: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: dateInDateFormat)
        let month = calendar.component(.month, from: dateInDateFormat)
        let day = calendar.component(.day, from: dateInDateFormat)
        let hour = calendar.component(.hour, from: timeInDateFormat)
        let minute = calendar.component(.minute, from: timeInDateFormat)
        let second = calendar.component(.second, from: timeInDateFormat)
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        let newDateAndTime = calendar.date(from: dateComponents)
        return newDateAndTime
    }
}
