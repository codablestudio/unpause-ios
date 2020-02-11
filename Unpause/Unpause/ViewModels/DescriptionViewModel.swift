//
//  DescriptionViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import RxSwift

class DescriptionViewModel {
    
    private var textInDescriptionTextView: String?
    var textInEmailTextFieldChanges = PublishSubject<String?>()
    
    init(arrivalTime: Date?, leavingTime: Date?) {
        setUpObservables()
        HomeViewModel.forceRefresh.onNext(())
    }
    
    private func setUpObservables() {
        
    }
}
