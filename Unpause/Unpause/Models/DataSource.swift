//
//  DataSource.swift
//  Unpause
//
//  Created by Krešimir Baković on 14/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import DifferenceKit

enum ShiftsTableViewItem: Differentiable {
    typealias DifferenceIdentifier = String
    
    case shift(Shift)
    case empty
    case loading
    
    var differenceIdentifier: String {
        switch self {
        case .shift(let shift):
            return shift.differenceIdentifier
        case .empty:
            return "-1"
        case .loading:
            return "-2"
        }
    }
    
    func isContentEqual(to source: ShiftsTableViewItem) -> Bool {
        switch (self, source) {
        case (.empty, .empty), (.loading, .loading):
            return true
        case (.shift(let lhs), .shift(let rhs)):
            return lhs.isContentEqual(to: rhs)
        default:
            return false
        }
    }
}
