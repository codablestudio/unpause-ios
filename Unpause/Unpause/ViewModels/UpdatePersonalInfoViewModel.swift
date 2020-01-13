//
//  UpdatePersonalInfoViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 07/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class UpdatePersonalInfoViewModel {
    
    private let disposeBag = DisposeBag()
    private let updatePersonalInfoNetworking = UpdatePersonalInfoNetworking()
    
    private var textInNewFirstNameTextField: String?
    private var textInNewLastNameTextField: String?
    
    var textInNewFirstNameTextFieldChanges = PublishSubject<String?>()
    var textInNewLastNameTextFieldChanges = PublishSubject<String?>()
    var updateInfoButtonTapped = PublishSubject<Void>()
    
    var updateInfoResponse: Observable<UpdateResponse>!
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInNewFirstNameTextFieldChanges.subscribe(onNext: { [weak self] (text) in
            guard let `self` = self else { return }
            self.textInNewFirstNameTextField = text
        }).disposed(by: disposeBag)
        
        textInNewLastNameTextFieldChanges.subscribe(onNext: { [weak self] (text) in
            guard let `self` = self else { return }
            self.textInNewLastNameTextField = text
        }).disposed(by: disposeBag)
        
        updateInfoResponse = updateInfoButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<UpdateResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.updatePersonalInfoNetworking.updateUserWith(newFirstName: self.textInNewFirstNameTextField, newLastName: self.textInNewLastNameTextField)
            })
    }
}
