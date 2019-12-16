//
//  RegisterViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 16/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class RegisterViewModel {
    
    private let disposeBag = DisposeBag()
    
    private var textInFirstNameTextField: String?
    private var textInLastNameTextField: String?
    private var textInEmailTextField: String?
    private var textInNewPasswordTextField: String?
    
    var textInFirstNameTextFieldChanges = PublishSubject<String?>()
    var textInLastNameTextFieldChanges = PublishSubject<String?>()
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var textInNewPasswordTextFieldChanges = PublishSubject<String?>()
    
    init() {
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInFirstNameTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInFirstNameTextField = newValue
        }).disposed(by: disposeBag)
        
        textInLastNameTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInLastNameTextField = newValue
        }).disposed(by: disposeBag)
        
        textInEmailTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInEmailTextField = newValue
        }).disposed(by: disposeBag)
        
        textInNewPasswordTextFieldChanges.subscribe(onNext: { [weak self] (newValue) in
            self?.textInNewPasswordTextField = newValue
        }).disposed(by: disposeBag)
    }
}
