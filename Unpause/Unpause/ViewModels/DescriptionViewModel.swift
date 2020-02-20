//
//  DescriptionViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import RxSwift

class DescriptionViewModel {
    
    private let disposeBag = DisposeBag()
    private let shiftNetworking = ShiftNetworking()
    
    private let arrivalDateAndTime: Date?
    private let leavingDateAndTime: Date?
    
    private var textInDescriptionTextView: String?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var saveButtonTapped = PublishSubject<Void>()
    
    var shiftSavingResponse: Observable<Response>!
    
    init(arrivalDateAndTime: Date?, leavingDateAndTime: Date?) {
        self.arrivalDateAndTime = arrivalDateAndTime
        self.leavingDateAndTime = leavingDateAndTime
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInEmailTextFieldChanges.subscribe(onNext: { [weak self] (descriptionText) in
            guard let `self` = self else { return }
            self.textInDescriptionTextView = descriptionText
        }).disposed(by: disposeBag)
        
        shiftSavingResponse = saveButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self,
                    let arrivalDateAndTime = self.arrivalDateAndTime,
                    let leavingDateAndTime = self.leavingDateAndTime else {
                        return Observable.just(Response.error(UnpauseError.emptyError))
                }
                
                let arrivalDateAndTimeInTimeStampFormat = Formatter.shared.convertDateIntoTimeStamp(date: arrivalDateAndTime)
                let leavingDateAndTimeInTimeStampFormat = Formatter.shared.convertDateIntoTimeStamp(date: leavingDateAndTime)
                
                let newShift = Shift()
                newShift.arrivalTime = arrivalDateAndTimeInTimeStampFormat
                newShift.exitTime = leavingDateAndTimeInTimeStampFormat
                newShift.description = self.textInDescriptionTextView
                
                return self.shiftNetworking.saveNewShift(newShiftWithExitTime: newShift)
            })
    }
}
