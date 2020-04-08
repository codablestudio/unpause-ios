//
//  UpdatePersonalInfoViewModelMock.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 08/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import XCTest
import RxSwift
import RxTest

class UpdatePersonalInfoViewModelMock: UpdatePersonalInfoViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let updatePersonalInfoNetworking = UpdatePersonalInfoNetworkingMock()
    
    private var textInNewFirstNameTextField: String?
    private var textInNewLastNameTextField: String?
    
    var textInNewFirstNameTextFieldChanges = PublishSubject<String?>()
    var textInNewLastNameTextFieldChanges = PublishSubject<String?>()
    var updateInfoButtonTapped = PublishSubject<Void>()
    
    var updateInfoResponse: Observable<Response>!
    
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
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                return self.updatePersonalInfoNetworking.updateUserWith(newFirstName: self.textInNewFirstNameTextField, newLastName: self.textInNewLastNameTextField)
            })
    }
}
