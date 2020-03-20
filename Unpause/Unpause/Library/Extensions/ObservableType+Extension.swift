//
//  ObservableType+Extension.swift
//
//
//  Created by Krešimir Baković on 20/03/2020.
//  Copyright © 2020 Codable Studio. All rights reserved.
//

import RxSwift
import Firebase

extension ObservableType where Element == DocumentSnapshot {
    func mapShifts() -> Observable<[Shift]> {
        return map({ document -> [Shift] in
            if let data = document.data() {
                return ShiftFactory.createShifts(data)
            }
            return []
        })
    }
}
