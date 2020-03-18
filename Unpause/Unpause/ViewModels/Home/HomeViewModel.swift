//
//  HomeViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel {
    
    private let disposeBag = DisposeBag()
    private let homeNetworking = HomeNetworking()
    private let shiftNetworking = ShiftNetworking()
    
    var usersLastCheckInTimeRequest: Observable<LastCheckInResponse>!
    var userChecksIn = PublishSubject<Bool>()
    var checkInResponse: Observable<Response>!
    
    private let _isFetchingLastShift = ActivityIndicator()
    var fetchingLastShift: Observable<Bool> {
        return _isFetchingLastShift.asObservable()
    }
    
    static let forceRefresh = PublishSubject<Void>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        usersLastCheckInTimeRequest = HomeViewModel.forceRefresh
            .startWith(())
            .flatMapLatest({ [weak self] _ -> Observable<LastCheckInResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.homeNetworking.getUsersLastCheckInTime()
                    .trackActivity(self._isFetchingLastShift)
            })
        
        checkInResponse = userChecksIn
            .flatMapLatest({ [weak self] userChecksIn -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                let timeAtThisMoment = Date()
                if userChecksIn {
                    SessionManager.shared.currentUser?.lastCheckInDateAndTime = timeAtThisMoment
                    let newShift = Shift()
                    newShift.arrivalTime = Formatter.shared.convertDateIntoTimeStamp(date: timeAtThisMoment)
                    return self.shiftNetworking.saveNewShift(newShift: newShift)
                } else {
                    SessionManager.shared.currentUser?.lastCheckOutDateAndTime = timeAtThisMoment
                    return Observable.empty()
                }
            })
    }
}
