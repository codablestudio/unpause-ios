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
    
//    func convertTimeStampIntoDate(timeStamp: Timestamp?) -> Date? {
//        
//    }
}
