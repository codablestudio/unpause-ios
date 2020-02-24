//
//  Shift.swift
//  Unpause
//
//  Created by Krešimir Baković on 12/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseFirestore
import DifferenceKit

class Shift: Differentiable, Equatable {
    typealias DifferenceIdentifier = String
    
     var differenceIdentifier: String {
        let arrivalDateAndTimeInDateFormat = Formatter.shared.convertTimeStampIntoString(timeStamp: arrivalTime)
        let exitDateAndTimeInDateFormat = Formatter.shared.convertTimeStampIntoString(timeStamp: exitTime)
        return "\(arrivalDateAndTimeInDateFormat)+\(exitDateAndTimeInDateFormat)"
    }
    
    var arrivalTime: Timestamp?
    var description: String?
    var exitTime: Timestamp?
    
    func isContentEqual(to source: Shift) -> Bool {
        return arrivalTime == source.arrivalTime && exitTime == source.exitTime
    }
    
    static func ==(lhs: Shift, rhs: Shift) -> Bool {
        return lhs.arrivalTime == rhs.arrivalTime && lhs.exitTime == rhs.exitTime && lhs.description == rhs.description
    }
}
