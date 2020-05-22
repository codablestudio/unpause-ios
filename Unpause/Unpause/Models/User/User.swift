//
//  User.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import SwiftyStoreKit
import RxSwift

class User: NSObject, NSCoding {
    var firstName: String?
    var lastName: String?
    var email: String?
    
    var lastCheckInDateAndTime: Date?
    var lastCheckOutDateAndTime: Date?
    
    var monthSubscriptionEndingDate: Date?
    var yearSubscriptionEndingDate: Date?
    var isPromoUser = false
    
    var company: Company?
    
    required init?(coder: NSCoder) {
        firstName = coder.decodeObject(forKey: "firstName") as? String
        lastName = coder.decodeObject(forKey: "lastName") as? String
        email = coder.decodeObject(forKey: "email") as? String
        company = coder.decodeObject(forKey: "company") as? Company
    }
    
    init(firstName: String?, lastName: String?, email: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }

    func encode(with coder: NSCoder) {
        coder.encode(firstName, forKey: "firstName")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(email, forKey: "email")
        coder.encode(company, forKey: "company")
    }
}

// MARK: Subscriptions
extension User {
    func checkUserHasValidSubscription(onCompleted: @escaping (Bool) -> Void ) {
        return IAPManager.shared.updateUserSubscriptionStatus(onCompleted: {
            if let monthEndingDate = self.monthSubscriptionEndingDate, monthEndingDate > Date() {
                onCompleted(true)
            } else if let yearEndingDate = self.yearSubscriptionEndingDate, yearEndingDate > Date() {
                onCompleted(true)
            } else {
                onCompleted(self.isPromoUser)
            }
        })
    }
}
