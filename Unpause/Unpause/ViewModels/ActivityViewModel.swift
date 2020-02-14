//
//  ActivityViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 19/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import RxSwift

class ActivityViewModel {
    
    private let shiftNetworking = ShiftNetworking()
    
    var shiftsRequest: Observable<[ShiftsTableViewItem]>!
    var refreshTrigger = PublishSubject<Void>()
    
    init() {
        shiftsRequest = refreshTrigger
            .startWith(())
            .flatMapLatest({ [weak self] _ -> Observable<ShiftsResponse> in
                guard let `self` = self else { return Observable.empty() }
                return self.shiftNetworking.fetchShifts()
            })
            .map({ shiftsResponse -> [ShiftsTableViewItem] in
                switch shiftsResponse {
                case .success(let shifts):
                    var res = [ShiftsTableViewItem]()
                    for shift in shifts {
                        res.append(.shift(shift))
                    }
                    return res
                case .error(let err):
                    print("error \(err)")
                }
                return []
            })
    }
}
