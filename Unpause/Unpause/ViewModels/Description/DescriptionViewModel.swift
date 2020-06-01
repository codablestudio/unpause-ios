//
//  DescriptionViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import RxSwift

class DescriptionViewModel: DescriptionViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let shiftNetworking: ShiftNetworkingProtocol
    
    private let arrivalDateAndTime: Date?
    private let leavingDateAndTime: Date?
    private var navigationFromCustomShift: Bool?
    
    private var textInDescriptionTextView: String?
    
    var shiftToEdit: ShiftsTableViewItem?
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var saveButtonTapped = PublishSubject<Void>()
    var saveButtonFromTableViewTapped = PublishSubject<Void>()
    
    var shiftSavingResponse: Observable<Response>!
    var shiftEditingResponse: Observable<Response>!
    
    init(shiftNetworking: ShiftNetworkingProtocol,
         arrivalDateAndTime: Date?,
         leavingDateAndTime: Date?,
         navigationFromCustomShift: Bool) {
        self.shiftNetworking = shiftNetworking
        self.arrivalDateAndTime = arrivalDateAndTime
        self.leavingDateAndTime = leavingDateAndTime
        self.navigationFromCustomShift = navigationFromCustomShift
        
        setUpObservables()
    }
    
    init(shiftNetworking: ShiftNetworkingProtocol, arrivalDateAndTime: Date?, leavingDateAndTime: Date?, shiftToEdit: ShiftsTableViewItem) {
        self.shiftNetworking = shiftNetworking
        self.arrivalDateAndTime = arrivalDateAndTime
        self.leavingDateAndTime = leavingDateAndTime
        self.shiftToEdit = shiftToEdit
        
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
                
                if let navigationFromCustomShift = self.navigationFromCustomShift, navigationFromCustomShift {
                    return self.shiftNetworking.saveNewShift(newShift: newShift)
                } else {
                    return self.shiftNetworking.removeShiftWithOutExitTimeAndSaveNewShift(newShiftWithExitTime: newShift)
                }
            })
        
        shiftEditingResponse = saveButtonFromTableViewTapped
            .flatMapLatest({ [weak self] _ -> Observable<ShiftsResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.shiftNetworking.fetchShifts()
            })
            .flatMapLatest({ [weak self] shiftResponse -> Observable<ShiftsResponse> in
                guard let `self` = self,
                    let shiftToEdit = self.shiftToEdit?.shift else {
                        return Observable.just(ShiftsResponse.error(UnpauseError.emptyError))
                }
                
                switch shiftResponse {
                case .success(let shifts):
                    let newShiftArray = self.editShiftAndSaveItToArray(shiftToFind: shiftToEdit, shifts: shifts)
                    return Observable.just(ShiftsResponse.success(newShiftArray))
                case .error(let error):
                    return Observable.just(ShiftsResponse.error(error))
                }
            })
            .flatMapLatest({ [weak self] shiftResponse -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                switch shiftResponse {
                case .success(let newShiftArray):
                    return self.shiftNetworking.saveNewShiftsArrayOnServer(newShiftArray: newShiftArray)
                case .error(_):
                    return Observable.just(())
                }
            })
            .flatMapLatest({ _ -> Observable<Response> in
                return Observable.just(Response.success)
            })
    }
    
    private func findAndEditShiftInShiftsArray(shiftToFind: Shift, shifts: [Shift]) -> [Shift] {
        var newShiftsArray = [Shift]()
        for shift in shifts {
            if shift == shiftToFind {
                let newShift = Shift()
                newShift.arrivalTime = Formatter.shared.convertDateIntoTimeStamp(date: arrivalDateAndTime)
                newShift.exitTime = Formatter.shared.convertDateIntoTimeStamp(date: leavingDateAndTime)
                newShift.description = textInDescriptionTextView
                newShiftsArray.append(newShift)
            } else {
                newShiftsArray.append(shift)
            }
        }
        return newShiftsArray
    }
    
    private func editShiftAndSaveItToArray(shiftToFind: Shift, shifts: [Shift]) -> [Shift] {
        var newShiftsArray = shifts
        for (index, element) in shifts.enumerated() {
            if element == shiftToFind {
                newShiftsArray.remove(at: index)
            }
        }
        let newShift = Shift()
        newShift.arrivalTime = Formatter.shared.convertDateIntoTimeStamp(date: arrivalDateAndTime)
        newShift.exitTime = Formatter.shared.convertDateIntoTimeStamp(date: leavingDateAndTime)
        newShift.description = textInDescriptionTextView
        newShiftsArray = ShiftFactory.addShiftOnRightPlaceInShiftArray(shifts: newShiftsArray, newShift: newShift)
        return newShiftsArray
    }
}
