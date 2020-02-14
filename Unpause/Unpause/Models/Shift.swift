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

class Shift: Differentiable {
    typealias DifferenceIdentifier = Int
    
     var differenceIdentifier: Int {
        return 123
    }
    
    var arrivalTime: Timestamp?
    var description: String?
    var exitTime: Timestamp?
    
    func isContentEqual(to source: Shift) -> Bool {
        return arrivalTime == source.arrivalTime
    }
}
