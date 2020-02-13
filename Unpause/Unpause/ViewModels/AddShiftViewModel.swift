//
//  AddShiftViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 15/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

class AddShiftViewModel {
    
    init() {}
    
    func makeNewDateAndTimeWithCheckInDateAnd(timeInDateFormat: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        guard let lastCheckInDateAndTime = SessionManager.shared.currentUser?.lastCheckInDateAndTime else {
            return Date()
        }
        
        let year = calendar.component(.year, from: lastCheckInDateAndTime)
        let month = calendar.component(.month, from: lastCheckInDateAndTime)
        let day = calendar.component(.day, from: lastCheckInDateAndTime)
        let hour = calendar.component(.hour, from: timeInDateFormat)
        let minute = calendar.component(.minute, from: timeInDateFormat)
        let second = calendar.component(.second, from: timeInDateFormat)
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        let newDateAndTime = calendar.date(from: dateComponents)
        return newDateAndTime
    }
    
    func makeNewDateAndTimeInDateFormat(dateInDateFormat: Date, timeInDateFormat: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: dateInDateFormat)
        let month = calendar.component(.month, from: dateInDateFormat)
        let day = calendar.component(.day, from: dateInDateFormat)
        let hour = calendar.component(.hour, from: timeInDateFormat)
        let minute = calendar.component(.minute, from: timeInDateFormat)
        let second = calendar.component(.second, from: timeInDateFormat)
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        let newDateAndTime = calendar.date(from: dateComponents)
        return newDateAndTime
    }
    
    func findTimeDifference(firstDate: Date, secondDate: Date) -> (String, String) {
        let timeDifferenceInSeconds = secondDate.timeIntervalSince1970 - firstDate.timeIntervalSince1970
        let hours = String(Int(timeDifferenceInSeconds / 3600))
        let minutes = String(Int((timeDifferenceInSeconds.truncatingRemainder(dividingBy: 3600)) / 60))
        return (hours,minutes)
    }
}
