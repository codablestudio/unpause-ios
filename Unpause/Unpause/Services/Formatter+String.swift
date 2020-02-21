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
    
    /// Date -> String(HH:mm)
    func convertTimeIntoString(from timeInDateFormat: Date) -> String {
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: timeInDateFormat)
        let minutes = calendar.component(.minute, from: timeInDateFormat)
        let twoDigitsHour = convertOneDigitiToTwoDigitis(oneDigitTime: hour)
        let twoDigitMinutes = convertOneDigitiToTwoDigitis(oneDigitTime: minutes)
        let timeInStringFormat = "\(twoDigitsHour):\(twoDigitMinutes)"
        return timeInStringFormat
    }
    
    /// Date -> String(dd.MM.yyyy)
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
    
    /// TimeStamp -> String(dd.MM.yyyy)
    func convertTimeStampIntoString(timeStamp: Timestamp?) -> String {
        let dateInDateFormat = convertTimeStampIntoDate(timeStamp: timeStamp)
        guard let date = dateInDateFormat else {
            return ""
        }
        let dateInStringFormat = convertDateIntoString(from: date)
        return dateInStringFormat
    }
    
    func convertDateIntoTimeStamp(date: Date?) -> Timestamp? {
        guard let date = date else {
            return Timestamp()
        }
        let timeStamp = Timestamp(date: date)
        return timeStamp
    }
    
    private func convertOneDigitiToTwoDigitis(oneDigitTime: Int) -> String {
        let oneDigitTimeAsString = String(oneDigitTime)
        if oneDigitTimeAsString.count == 1 {
            return "0" + oneDigitTimeAsString
        } else {
            return oneDigitTimeAsString
        }
    }
}
