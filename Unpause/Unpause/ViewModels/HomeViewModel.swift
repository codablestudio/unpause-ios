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
    private let signedInUserEmail: String
    
    var checkInButtonTapped = PublishSubject<Void>()
    
    init(signedInUserEmail: String) {
        self.signedInUserEmail = signedInUserEmail
        setUpObservables()
    }
    
    private func setUpObservables() {
        checkInButtonTapped.subscribe(onNext: { _ in
            // TODO: Do check in for user
            }).disposed(by: disposeBag)
    }
}
