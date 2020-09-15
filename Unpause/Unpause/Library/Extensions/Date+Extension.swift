//
//  Date+Extension.swift
//  Unpause
//
//  Created by Krešimir Baković on 15/09/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}
