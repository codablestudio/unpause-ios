//
//  AddCompanyViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 06/03/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class AddCompanyViewModel: AddCompanyViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let companyNetworking: CompanyNetworkingProtocol
    
    var textInCompanyNameTextFieldChanges = PublishSubject<String?>()
    var textInCompanyPassCodeTextFieldChanges = PublishSubject<String?>()
    var addCompanyButtonTapped = PublishSubject<Void>()
    
    var companyAddingResponse: Observable<Response>!
    
    private var textInCompanyNameTextField: String?
    private var textInCompanyPassCodeTextField: String?
    
    var registeredUserEmail: String?
    
    init(companyNetworking: CompanyNetworkingProtocol,
         registeredUserEmail: String?) {
        self.companyNetworking = companyNetworking
        self.registeredUserEmail = registeredUserEmail
        
        setUpObservables()
    }
    
    private func setUpObservables() {
        textInCompanyNameTextFieldChanges.subscribe(onNext: { [weak self] newText in
            guard let `self` = self else { return }
            self.textInCompanyNameTextField = newText
        }).disposed(by: disposeBag)
        
        textInCompanyPassCodeTextFieldChanges.subscribe(onNext: { [weak self] newText in
            guard let `self` = self else { return }
            self.textInCompanyPassCodeTextField = newText
        }).disposed(by: disposeBag)
        
        companyAddingResponse = addCompanyButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self else { return Observable.empty() }
                return self.companyNetworking.addCompanyReferenceToUser(userEmail: self.registeredUserEmail,
                                                                        companyPassCode: self.textInCompanyPassCodeTextField)
            })
    }
}
