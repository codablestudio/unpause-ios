//
//  LoginViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 11/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    let disposeBag = DisposeBag()
    
    var textInEmailTextField = PublishSubject<String?>()
    var textInPasswordTextField = PublishSubject<String?>()
    
    init() {
        textInEmailTextField.subscribe(onNext: { (newValue) in
        print("\(newValue!)")
        }).disposed(by: disposeBag)
        
        textInPasswordTextField.subscribe(onNext: { (newValue) in
            print("\(newValue!)")
            
            }).disposed(by: disposeBag)
    }
}
