//
//  SessionManager.swift
//  Unpause
//
//  Created by Krešimir Baković on 23/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

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
        
        saveCurrentUserToUserDefaults()
    }
    
    func logOut() {
        currentUser = nil
        NotificationManager.shared.notificationCenter.removeAllPendingNotificationRequests()
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    func userLoggedIn() -> Bool {
        return currentUser != nil
    }
    
    func saveCurrentUserToUserDefaults() {
        let userDefaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: currentUser as Any)
        userDefaults.set(data, forKey: currentUserKey)
    }
    
    func currentUserHasConnectedCompany() -> Bool {
        guard let _ = SessionManager.shared.currentUser?.company else {
            return false
        }
        return true
    }
    
    func getCurrentUserEmail() -> String {
        guard let email = SessionManager.shared.currentUser?.email else {
            return ""
        }
        return email
    }
}
