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
    
    private let currentUserKey = "currentUserKey"
    
    var currentUser: User?
    
    private init() {
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.data(forKey: currentUserKey),
            let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User {
            currentUser = user
        }
    }
}

// MARK: Login / Logout

extension SessionManager {
    func logIn(_ user: User) {
        currentUser = user
        
        let userDefaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: currentUser as Any)
        userDefaults.set(data, forKey: currentUserKey)
    }
    
    func logOut() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    func userLoggedIn() -> Bool {
        return currentUser != nil
    }
}
