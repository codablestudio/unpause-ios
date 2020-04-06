//
//  HomeViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel: HomeViewModelProtocol {

    private let disposeBag = DisposeBag()
    private let homeNetworking: HomeNetworkingProtocol
    private let shiftNetworking: ShiftNetworkingProtocol
    
    var usersLastCheckInTimeRequest: Observable<LastCheckInResponse>!
    var checkInResponse: Observable<Response>!
    var fetchingLastShift: Observable<Bool> {
        return _isFetchingLastShift.asObservable()
    }
    
    private let _isFetchingLastShift = ActivityIndicator()

    static let forceRefresh = PublishSubject<Void>()
    var userChecksIn = PublishSubject<Bool>()
    
    init(homeNetworking: HomeNetworkingProtocol,
         shiftNetworking: ShiftNetworkingProtocol) {
        self.homeNetworking = homeNetworking
        self.shiftNetworking = shiftNetworking
        
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
