//
//  HomeViewModelMock.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 07/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import XCTest
import RxSwift
import RxTest

class HomeViewModelMock: HomeViewModelProtocol {
    
    private let homeNetworking = HomeNetworkingMock()
    private let shiftNetworking = ShiftNetworkingMock()
    private let disposeBag = DisposeBag()
    
    var usersLastCheckInTimeRequest: Observable<LastCheckInResponse>!
    var checkInResponse: Observable<Response>!
    var fetchingLastShift: Observable<Bool>! {
        return _isFetchingLastShift.asObservable()
    }
    
    private let _isFetchingLastShift = ActivityIndicator()
    
    static let forceRefresh = PublishSubject<Void>()
    var userChecksIn = PublishSubject<Bool>()
    
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
