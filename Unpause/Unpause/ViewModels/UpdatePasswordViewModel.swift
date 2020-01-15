//
//  UpdatePasswordViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class UpdatePasswordViewModel {
    
    private let disposeBag = DisposeBag()
    private let updatePasswordNetworking = UpdatePasswordNetworking()
    
    var textInCurrentPasswordTextFieldChanges = PublishSubject<String?>()
    var textInNewPasswordTextFieldChanges = PublishSubject<String?>()
    var updatePasswordButtonTapped = PublishSubject<Void>()
    
    private var textInCurrentPasswordTextField: String?
    private var textInNewPasswordTextField: String?
    
    var updatePasswordResponse: Observable<UpdateResponse>!
    
    
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
        
        updatePasswordResponse = updatePasswordButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<UpdateResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.updatePasswordNetworking.updateCurrentUserPassword(self.textInCurrentPasswordTextField,
                                                                               with: self.textInNewPasswordTextField)
            })
    }
}
