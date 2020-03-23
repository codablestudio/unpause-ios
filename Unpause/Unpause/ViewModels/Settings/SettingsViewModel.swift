//
//  SettingsViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class SettingsViewModel {
    
    private let disposeBag = DisposeBag()
    
    var logOutButtonTapped = PublishSubject<Void>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        logOutButtonTapped.subscribe(onNext: { _ in
            SessionManager.shared.logOut()
            Coordinator.shared.logOut()
        }).disposed(by: disposeBag)
    }
}
