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
        usersLastCheckInTimeRequest = homeNetworking.getUsersLastCheckInTime()
            .trackActivity(_isFetchingLastShift)
        
        checkInResponse = userChecksIn
            .flatMapLatest({ [weak self] userChecksIn -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                let timeAtThisMoment = Date()
                if userChecksIn {
                    SessionManager.shared.currentUser?.lastCheckInDateAndTime = timeAtThisMoment
                    return self.homeNetworking.checkInUser(with: timeAtThisMoment)
                } else {
                    SessionManager.shared.currentUser?.lastCheckOutDateAndTime = timeAtThisMoment
                    return Observable.empty()
                }
            })
        
        HomeViewModel.forceRefresh
            .subscribe(onNext: { _ in
                print("I should refresh")
            }).disposed(by: disposeBag)
    }
}
