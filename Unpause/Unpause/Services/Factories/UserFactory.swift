//
//  UserFactory.swift
//  Unpause
//
//  Created by Krešimir Baković on 08/01/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

class UserFactory {
    
    static func createUser(from document: DocumentSnapshot) throws -> User {
        guard let email = document.get("email") as? String else { throw UnpauseError.defaultError }
        guard let firstName = document.get("firstName") as? String else { throw UnpauseError.defaultError }
        guard let lastName = document.get("lastName") as? String else { throw UnpauseError.defaultError }
        return User(firstName: firstName, lastName: lastName, email: email)
    }
    
    static func createUser(from googleUser: GIDGoogleUser) -> User {
        let email = googleUser.profile.email
        let firstName = googleUser.profile.name
        let lastName = googleUser.profile.familyName
        return User(firstName: firstName, lastName: lastName, email: email)
    }
    
    static func initialize(firstName: String, lastName: String, email: String) -> User {
        let newUser = User(firstName: firstName, lastName: lastName, email: email)
        return newUser
    }
}
