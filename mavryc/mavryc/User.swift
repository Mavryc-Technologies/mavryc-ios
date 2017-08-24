//
//  User.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class User {
    var firstName: String?
    var lastName: String?
    var email: String? // is the username
    var phone: String? = nil
    var birthdate: Date? = nil
    
    static func isUserLoggedIn() -> Bool {
        // :TODO: go look at user data and see if there is a user
        return false
    }
}
