//
//  UpdatePersonalInfoViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 07/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class UpdatePersonalInfoViewModel: UpdatePersonalInfoViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let updatePersonalInfoNetworking: UpdatePersonalInfoNetworkingProtocol
    
    private var textInNewFirstNameTextField: String?
    private var textInNewLastNameTextField: String?
    
    var textInNewFirstNameTextFieldChanges = PublishSubject<String?>()
    var textInNewLastNameTextFieldChanges = PublishSubject<String?>()
    var updateInfoButtonTapped = PublishSubject<Void>()
    
    var updateInfoResponse: Observable<Response>!
    
    init(updatePersonalInfoNetworking: UpdatePersonalInfoNetworkingProtocol) {
        self.updatePersonalInfoNetworking = updatePersonalInfoNetworking
        
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
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                return self.updatePersonalInfoNetworking.updateUserWith(newFirstName: self.textInNewFirstNameTextField, newLastName: self.textInNewLastNameTextField)
            })
    }
}
