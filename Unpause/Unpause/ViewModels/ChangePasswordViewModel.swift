//
//  ChangePasswordViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class ChangePasswordViewModel {
    
    private let disposeBag = DisposeBag()
    private let changePasswordNetworking = ChangePasswordNetworking()
    
    var textInCurrentPasswordTextFieldChanges = PublishSubject<String?>()
    var textInNewPasswordTextFieldChanges = PublishSubject<String?>()
    var changePasswordButtonTapped = PublishSubject<Void>()
    
    private var textInCurrentPasswordTextField: String?
    private var textInNewPasswordTextField: String?
    
    var changePasswordResponse: Observable<Response>!
    
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInCurrentPasswordTextFieldChanges.subscribe(onNext: { [weak self] (text) in
            self?.textInCurrentPasswordTextField = text
        }).disposed(by: disposeBag)
        
        textInNewPasswordTextFieldChanges.subscribe(onNext: { [weak self] (text) in
            self?.textInNewPasswordTextField = text
        }).disposed(by: disposeBag)
        
        changePasswordResponse = changePasswordButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                return self.changePasswordNetworking.updateCurrentUserPassword(self.textInCurrentPasswordTextField,
                                                                               with: self.textInNewPasswordTextField)
            })
    }
}
