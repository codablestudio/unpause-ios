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
    
    var changePersonalInfoButtonTapped = PublishSubject<Void>()
    var changePasswordButtonTapped = PublishSubject<Void>()
    var logOutButtonTapped = PublishSubject<Void>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        changePersonalInfoButtonTapped.subscribe(onNext: { _ in
            // TODO: Make everything to change personal info
            print("Change personal info")
        }).disposed(by: disposeBag)
        
        changePasswordButtonTapped.subscribe(onNext: { _ in
            // TODO: Make everything to provide user funcionality to change password
            print("Change password")
        }).disposed(by: disposeBag)
        
        logOutButtonTapped.subscribe(onNext: { _ in
            SessionManager.shared.logOut()
            Coordinator.shared.logOut()
        }).disposed(by: disposeBag)
    }
}
