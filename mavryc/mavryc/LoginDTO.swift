//
//  LoginDTO.swift
//  mavryc
//
//  Created by Jake on 4/26/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation


struct LoginDTO {
    let email: String
    let password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

}
