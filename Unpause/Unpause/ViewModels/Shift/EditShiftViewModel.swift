//
//  CustomShiftViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol EditShiftViewModelProtocol {
    var saveButtonTapped:  PublishSubject<Void> { get }
    var textInDescriptionTextViewChanges:  PublishSubject<String?> { get }
    var arrivalDateAndTimeChanges:  PublishSubject<Date?> { get }
    var leavingDateAndTimeChanges:  PublishSubject<Date?> { get }
    
    var shiftEditingResponse: Observable<Response>! { get }
}

class EditShiftViewModel: EditShiftViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let shiftNetworking: ShiftNetworkingProtocol
    
    var saveButtonTapped = PublishSubject<Void>()
    var textInDescriptionTextViewChanges = PublishSubject<String?>()
    var arrivalDateAndTimeChanges = PublishSubject<Date?>()
    var leavingDateAndTimeChanges = PublishSubject<Date?>()
    
    var shiftEditingResponse: Observable<Response>!
    
    var textInDescriptionTextView: String?
    var arrivalDateAndTime: Date?
    var leavingDateAndTime: Date?
    
    var shiftToEdit: ShiftsTableViewItem
    
    init(shiftNetworking: ShiftNetworkingProtocol, shiftToEdit: ShiftsTableViewItem) {
        self.shiftToEdit = shiftToEdit
        self.shiftNetworking = shiftNetworking
        setUpObservables()
    }
    
    func setUpObservables() {
        textInDescriptionTextViewChanges.subscribe(onNext: { [weak self] descriptionText in
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
        
        shiftEditingResponse = saveButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<ShiftsResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.shiftNetworking.fetchShifts()
            })
            .flatMapLatest({ [weak self] shiftResponse -> Observable<ShiftsResponse> in
                guard let `self` = self,
                    let shiftToEdit = self.shiftToEdit.shift else {
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
