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
    
    static func storedUser() -> User? {

        if let userEmail: String = UserDefaults.standard.string(forKey: userEmailKey), let userPass: String = UserDefaults.standard.string(forKey: userPassKey) {
            return User(email: userEmail, password: userPass)
        }
        
        return nil
    }
    
    func save() {
        UserDefaults.standard.set(self.email, forKey: User.userEmailKey)
        UserDefaults.standard.set(self.password, forKey: User.userPassKey)
    }
}
