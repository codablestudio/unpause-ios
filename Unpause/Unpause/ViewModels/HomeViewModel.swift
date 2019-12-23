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
    
    var checkInButtonTapped = PublishSubject<Void>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        checkInButtonTapped.subscribe(onNext: { _ in
            print("Check in")
            // TODO: Do check in for user
        }).disposed(by: disposeBag)
    }
}
