//
//  ActivityViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import RxSwift

class ActivityViewModel {
    
    private let shiftNetworking = ShiftNetworking()
    private let disposeBag = DisposeBag()
    
    var shiftsRequest: Observable<[ShiftsTableViewItem]>!
    var refreshTrigger = PublishSubject<Void>()
    var dateInFromDatePickerChanges = PublishSubject<Date>()
    var dateInToDatePickerChanges = PublishSubject<Date>()
    
    private var dateInFromDatePicker: Date?
    private var dateInToDatePicker: Date?
    
    static var forceRefresh = PublishSubject<()>()
    
    init() {
        dateInFromDatePickerChanges
            .subscribe(onNext: { [weak self] date in
                guard let `self` = self else { return }
                let dateWithZeroTime = Formatter.shared.getDateWithStartingDayTime(fromDate: date)
                self.dateInFromDatePicker = dateWithZeroTime
            }).disposed(by: disposeBag)

        dateInToDatePickerChanges
            .subscribe(onNext: { [weak self] date in
                guard let `self` = self else { return }
                let dateWithZeroTime = Formatter.shared.getDateWithEndingDayTime(fromDate: date)
                self.dateInToDatePicker = dateWithZeroTime
            }).disposed(by: disposeBag)
        
        shiftsRequest = Observable.merge(ActivityViewModel.forceRefresh, refreshTrigger)
            .startWith(())
            .flatMapLatest({ [weak self] _ -> Observable<ShiftsResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.shiftNetworking.fetchShifts()
            })
            .flatMapLatest({ [weak self] shiftsResponse -> Observable<ShiftsResponse> in
                guard let `self` = self,
                    let fromDate = self.dateInFromDatePicker,
                    let toDate = self.dateInToDatePicker else {
                        return Observable.just(ShiftsResponse.error(UnpauseError.emptyError))
                }
                return self.shiftNetworking.filterShifts(fromDate: fromDate, toDate: toDate, allShifts: shiftsResponse)
            })
            .map({ shiftsResponse -> [ShiftsTableViewItem] in
                switch shiftsResponse {
                case .success(let shifts):
                    var response = [ShiftsTableViewItem]()
                    for shift in shifts {
                        response.append(.shift(shift))
                    }
                    
                    if shifts.isEmpty {
                        response.append(.empty)
                    }
                    
                    return response
                case .error(let error):
                    print("error \(error)")
                }
                return []
            })
    }
}
