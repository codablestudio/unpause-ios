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
    
    var userChecksIn = PublishSubject<Bool>()
    var checkInButtonTapped = PublishSubject<Void>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        userChecksIn.subscribe(onNext: { [weak self] (userChecksIn) in
            guard let `self` = self else { return }
            let timeAtThisMoment = Date()
            if userChecksIn {
                SessionManager.shared.currentUser?.lastCheckInDateAndTime = timeAtThisMoment
                self.homeNetworking.checkInUser(with: timeAtThisMoment)
            } else {
                SessionManager.shared.currentUser?.lastCheckOutDateAndTime = timeAtThisMoment
            }
        }).disposed(by: disposeBag)
    }
}
