//
//  ForgotPasswordViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class ForgotPasswordViewModel: ForgotPasswordViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let loginNetworking: LoginNetworkingProtocol
    
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    var sendRecoveryEmailButtonTapped = PublishSubject<Void>()
    
    var recoveryMailSendingResponse: Observable<Response>!
    
    var textInEmailTextField: String?
    
    init(loginNetworking: LoginNetworkingProtocol) {
        self.loginNetworking = loginNetworking
        
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInEmailTextFieldChanges.subscribe(onNext: { [weak self] newText in
            guard let `self` = self else { return }
            self.textInEmailTextField = newText
        }).disposed(by: disposeBag)
        
        recoveryMailSendingResponse = sendRecoveryEmailButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self,
                    let email = self.textInEmailTextField else {
                        return Observable.just(Response.error(UnpauseError.emptyError))
                }
                return self.loginNetworking.sendPasswordResetTo(email: email)
            })
    }
}
