//
//  AddShiftViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 15/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

class AddShiftViewModel {
    
    init() {
        
    }
    
    func convertTimeIntoString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatterString = formatter.string(from: date)
        let formatterDate = formatter.date(from: formatterString)
        formatter.dateFormat = "HH:mm"
        
        guard let formatedDate = formatterDate else {
            return ""
        }
        
        let time = formatter.string(from: formatedDate)
        return time
    }
    
    func convertDateIntoString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatterString = formatter.string(from: date)
        let formatterDate = formatter.date(from: formatterString)
        formatter.dateFormat = "dd.MM.yyyy"
        
        guard let formatedDate = formatterDate else {
            return ""
        }
        
        let date = formatter.string(from: formatedDate)
        return date
    }
}
