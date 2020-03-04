//
//  User.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase

class User: NSObject, NSCoding {
    var firstName: String?
    var lastName: String?
    var email: String?
    
    var lastCheckInDateAndTime: Date?
    var lastCheckOutDateAndTime: Date?
    
    var company: Company?
    
    required init?(coder: NSCoder) {
        firstName = coder.decodeObject(forKey: "firstName") as? String
        lastName = coder.decodeObject(forKey: "lastName") as? String
        email = coder.decodeObject(forKey: "email") as? String
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
    }
}
