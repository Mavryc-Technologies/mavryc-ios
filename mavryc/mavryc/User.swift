//
//  User.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class User {
    
    private static let userEmailKey = "userEmail"
    private static let userPassKey = "userPass"
    
    private static let userFirstnameKey = "userFirstnameKey"
    
    var email: String! // is the username
    var password: String!
    
    var firstName: String?
    var lastName: String?
    var phone: String? = nil
    var birthdate: Date? = nil
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    static func isUserLoggedIn() -> Bool {
        
        if let _ = self.storedUser() {
            return true
        }
        
        return false
    }
    
    // TODO: expand support for stored user to include more than just email (and pass)
    // TODO: move storage of pass to secure keychain
    static func storedUser() -> User? {
        
        if let name: String = UserDefaults.standard.string(forKey: userFirstnameKey), let userEmail: String = UserDefaults.standard.string(forKey: userEmailKey), let userPass: String = UserDefaults.standard.string(forKey: userPassKey) {
            let aUser = User(email: userEmail, password: userPass)
            aUser.firstName = name
            return aUser
        }

        if let userEmail: String = UserDefaults.standard.string(forKey: userEmailKey), let userPass: String = UserDefaults.standard.string(forKey: userPassKey) {
            return User(email: userEmail, password: userPass)
        }
        
        return nil
    }
    
    static func logout() {
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        UserDefaults.standard.removeObject(forKey: userPassKey)
    }
    
    func save() {
        UserDefaults.standard.set(self.email, forKey: User.userEmailKey)
        UserDefaults.standard.set(self.password, forKey: User.userPassKey)
        
        if let name = self.firstName {
            UserDefaults.standard.set(name, forKey: User.userFirstnameKey)
        }
    }
}
