//
//  Signup.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

struct SignupDTO {
    
    let email: String
    let firstName: String
    let lastName: String
    let password: String
    let phone: String?
    let birthday: String?
    
    init(email: String, firstName: String, lastName: String, password: String, phone: String? = nil, birthday: String? = nil) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.phone = phone
        self.birthday = birthday
    }
}
