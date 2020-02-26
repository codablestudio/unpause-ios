//
//  BossInfoViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 26/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

class BossInfoViewModel {
    
    private let disposeBag = DisposeBag()
    private let bossNetworking = BossNetworking()
    
    var saveButtonTouched = PublishSubject<Void>()
    var activityStarted = PublishSubject<Void>()
    var textInBossFirstNameTextFieldChanges = PublishSubject<String?>()
    var textInBossLastNameTextFieldChanges = PublishSubject<String?>()
    var textInBossEmailTextFieldChanges = PublishSubject<String?>()
    
    var bossSavingResponse: Observable<Response>!
    var bossFetchingResponse: Observable<BossFetchingResponse>!
    
    private var textInBossFirstNameTextField: String?
    private var textInBossLastNameTextField: String?
    private var textInBossEmailTextField: String?
    
    init() {
        textInBossFirstNameTextFieldChanges.subscribe(onNext: { [weak self] newText in
            guard let `self` = self else { return }
            self.textInBossFirstNameTextField = newText
        }).disposed(by: disposeBag)
        
        textInBossLastNameTextFieldChanges.subscribe(onNext: { [weak self] newText in
            guard let `self` = self else { return }
            self.textInBossLastNameTextField = newText
        }).disposed(by: disposeBag)
        
        textInBossEmailTextFieldChanges.subscribe(onNext: { [weak self] newText in
            guard let `self` = self else { return }
            self.textInBossEmailTextField = newText
        }).disposed(by: disposeBag)
        
        bossSavingResponse = saveButtonTouched
            .flatMapLatest({ [weak self] _ -> Observable<Response> in
                guard let `self` = self,
                    let bossEmail = self.textInBossEmailTextField,
                    let bossFirstName = self.textInBossFirstNameTextField,
                    let bossLastName = self.textInBossLastNameTextField else {
                        return Observable.just(Response.error(UnpauseError.emptyError))
                }
                return self.bossNetworking.addBossToCurrenUser(bossEmail: bossEmail,
                                                               bossFirstName: bossFirstName,
                                                               bossLastName: bossLastName)
            })
        
        bossFetchingResponse = activityStarted
            .flatMapLatest({ [weak self] _ -> Observable<BossFetchingResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.bossNetworking.fetchBoss()
            })
    }
}
