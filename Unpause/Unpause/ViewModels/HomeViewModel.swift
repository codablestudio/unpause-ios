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
    
    var usersLastCheckInTime: Observable<LastCheckInResponse>!
    
    var userChecksIn = PublishSubject<Bool>()
    
    var checkInResponse: Observable<Response>!
    
    static let forceRefresh = PublishSubject<Void>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        usersLastCheckInTime = homeNetworking.getUsersLastCheckInTime()
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
