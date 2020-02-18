//
//  Formatter.swift
//  Unpause
//
//  Created by Krešimir Baković on 10/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Formatter {
    
    static let shared = Formatter()
    
    private init() {}
    
    // Date -> String: HH:mm
    func convertTimeIntoString(from timeInDateFormat: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatterString = formatter.string(from: timeInDateFormat)
        let formatterDate = formatter.date(from: formatterString)
        formatter.dateFormat = "HH:mm"
        
        guard let formatedDate = formatterDate else {
            return ""
        }
        
        let timeInStringFormat = formatter.string(from: formatedDate)
        return timeInStringFormat
    }
    
    // Date -> String: dd.MM.yyyy
    func convertDateIntoString(from dateInDateFormat: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatterString = formatter.string(from: dateInDateFormat)
        let formatterDate = formatter.date(from: formatterString)
        formatter.dateFormat = "dd.MM.yyyy"
        
        guard let formatedDate = formatterDate else {
            return ""
        }
        
        let dateInStringFormat = formatter.string(from: formatedDate)
        return dateInStringFormat
    }
    
    func convertTimeStampIntoDate(timeStamp: Timestamp?) -> Date? {
        let date = timeStamp?.dateValue()
        return date
    }
    
    func convertDateIntoTimeStamp(date: Date?) -> Timestamp? {
        guard let date = date else {
            return Timestamp()
        }
        let timeStamp = Timestamp(date: date)
        return timeStamp
    }
    
    func getDateOneMontBeforeTodaysDate() -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: Date())
        let lastmonthInDateFormat = calendar.date(byAdding: .month, value: -1, to: Date())
        let lastMonth = calendar.component(.month, from: lastmonthInDateFormat!)
        let day = calendar.component(.day, from: Date())
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())
        
        dateComponents.year = year
        dateComponents.month = lastMonth
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        guard let dateOneMonthBeforeTodaysDate = calendar.date(from: dateComponents) else {
            return Date()
        }
        return dateOneMonthBeforeTodaysDate
    }
    // Date -> Date with 00:00 time
    func getDateWithStartingDayTime(fromDate: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: fromDate)
        let lastMonth = calendar.component(.month, from: fromDate)
        let day = calendar.component(.day, from: fromDate)
        
        dateComponents.timeZone = TimeZone(abbreviation: "GMT")
        dateComponents.year = year
        dateComponents.month = lastMonth
        dateComponents.day = day
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        guard let dateWithStartingDayTime = calendar.date(from: dateComponents) else {
            return Date()
        }
        return dateWithStartingDayTime
    }
    
    // Date -> Date with 23:59 time
    func getDateWithEndingDayTime(fromDate: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: fromDate)
        let lastMonth = calendar.component(.month, from: fromDate)
        let day = calendar.component(.day, from: fromDate)
        
        dateComponents.timeZone = TimeZone(abbreviation: "GMT")
        dateComponents.year = year
        dateComponents.month = lastMonth
        dateComponents.day = day
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        
        guard let dateWithEndingDayTime = calendar.date(from: dateComponents) else {
            return Date()
        }
        return dateWithEndingDayTime
    }
}
