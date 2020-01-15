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
    
    var userChecksIn = PublishSubject<Bool>()
    
    var checkInButtonTapped = PublishSubject<Void>()
    
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        userChecksIn.subscribe(onNext: { (userChecksIn) in
            let timeAtThisMoment = Date()
            if userChecksIn {
                SessionManager.shared.currentUser?.lastCheckInTime = timeAtThisMoment
            } else {
                SessionManager.shared.currentUser?.lastCheckOutTime = timeAtThisMoment
                // AT THIS MOMENT PRESENT ADDSHIFT VC
            }
        }).disposed(by: disposeBag)
    }
}
