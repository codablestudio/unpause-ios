//
//  Formatter+Date.swift
//  Unpause
//
//  Created by Krešimir Baković on 20/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Formatter {
    /// String(dd.MM.yyyy) -> Date: yyyy-MM-dd
    func convertStringIntoDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let formatterdate = formatter.date(from: string)
        formatter.dateFormat = "yyyy-MM-dd"
        let formatterString = formatter.string(from: formatterdate!)
        
        let date = formatter.date(from: formatterString)
        
        guard let formattedDate = date else {
            return Date()
        }
        return formattedDate
    }
    
    /// Date -> Date with 00:00 time
    func getDateWithStartingDayTime(fromDate: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: fromDate)
        let lastMonth = calendar.component(.month, from: fromDate)
        let day = calendar.component(.day, from: fromDate)
        
        //dateComponents.timeZone = TimeZone(abbreviation: "GMT")
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
    
    /// Date -> Date with 23:59 time
    func getDateWithEndingDayTime(fromDate: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: fromDate)
        let lastMonth = calendar.component(.month, from: fromDate)
        let day = calendar.component(.day, from: fromDate)
        
        //dateComponents.timeZone = TimeZone(abbreviation: "GMT")
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
    
    func convertTimeStampIntoDate(timeStamp: Timestamp?) -> Date? {
        let date = timeStamp?.dateValue()
        return date
    }
    
    func getTimeTwelveHoursFromCurrentTime() -> DateComponents? {
        guard let timeTwelveHoursFromNow = Calendar.current.date(byAdding: .hour, value: 12, to: Date()) else {
            return nil
        }
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: timeTwelveHoursFromNow)
        return dateComponents
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
    
    func getDateOneMontAfterTodaysDate() -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: Date())
        let nextMonthInDateFormat = calendar.date(byAdding: .month, value: 1, to: Date())
        let nextMonth = calendar.component(.month, from: nextMonthInDateFormat!)
        let day = calendar.component(.day, from: Date())
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())
        
        dateComponents.year = year
        dateComponents.month = nextMonth
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        guard let dateOneMonthAfterTodaysDate = calendar.date(from: dateComponents) else {
            return Date()
        }
        return dateOneMonthAfterTodaysDate
    }
    
    func getDateOneYearAfterTodaysDate() -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let nextYearInDateFormat = calendar.date(byAdding: .year, value: 1, to: Date())
        let nextYear = calendar.component(.year, from: nextYearInDateFormat!)
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let second = calendar.component(.second, from: Date())
        
        dateComponents.year = nextYear
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        guard let dateOneYearAfterTodaysDate = calendar.date(from: dateComponents) else {
            return Date()
        }
        return dateOneYearAfterTodaysDate
    }
    
    func getDateAndTimeWithZeroSeconds(from date: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = 0
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        guard let dateAndTimeWithZeroSeconds = calendar.date(from: dateComponents) else {
            return Date()
        }
        return dateAndTimeWithZeroSeconds
    }

    func findTimeDifference(firstDate: Date, secondDate: Date) -> (String, String) {
        let timeDifferenceInSeconds = secondDate.timeIntervalSince1970 - firstDate.timeIntervalSince1970
        let hours = String(Int(timeDifferenceInSeconds / 3600))
        let minutes = String(Int((timeDifferenceInSeconds.truncatingRemainder(dividingBy: 3600)) / 60))
        return (hours,minutes)
    }
    
    func findTimeDifferenceInHours(firstDate: Date, secondDate: Date) -> Double {
        let timeDifferenceInSeconds = secondDate.timeIntervalSince1970 - firstDate.timeIntervalSince1970
        let hours = round((timeDifferenceInSeconds / 3600)*100)/100
        return hours
    }
    
    func dateIsDayInCurrentWeek(date: Date) -> Bool {
        let currentComponents = Calendar.current.dateComponents([.weekOfYear], from: Date())
        let dateComponents = Calendar.current.dateComponents([.weekOfYear], from: date)
        guard let currentWeekOfYear = currentComponents.weekOfYear,
            let dateWeekOfYear = dateComponents.weekOfYear else {
                return false
        }
        return currentWeekOfYear == dateWeekOfYear
    }
    
    func getDayOfWeek(from date: Date) -> DayOfWeek? {
        let day = Calendar.current.component(.weekday, from: date)
        if day == 1 {
            return DayOfWeek.Sunday
        } else if day == 2 {
            return DayOfWeek.Monday
        } else if day == 3 {
            return DayOfWeek.Tuesday
        } else if day == 4 {
            return DayOfWeek.Wednesday
        } else if day == 5 {
            return DayOfWeek.Thursday
        } else if day == 6 {
            return DayOfWeek.Friday
        } else if day == 7 {
            return DayOfWeek.Saturday
        } else {
            return nil
        }
    }
}
