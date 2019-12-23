//
//  SessionManager.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation

class SessionManager {
    static var shared = SessionManager()
    
    var currentUser: User?
    
    private init() {}
}

// MARK: Login / Logout

extension SessionManager {
    func logIn(_ user: User) {
        currentUser = user
    }
    
    func logOut() {
        currentUser = nil
    }
    
    func userLoggedIn() -> Bool {
        return currentUser != nil
    }
}
