//
//  AddShiftViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

protocol AddShiftViewModelProtocol {
    func makeNewDateAndTimeWithCheckInDateAnd(timeInDateFormat: Date) -> Date?
    func makeNewDateAndTimeInDateFormat(dateInDateFormat: Date, timeInDateFormat: Date) -> Date?
}
