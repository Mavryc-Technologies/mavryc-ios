//
//  User.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class User: Object, Mappable {
    dynamic var firstName: String!
    dynamic var lastName: String!
    dynamic var email: String! // is the username
    dynamic var phone: String? = nil
    dynamic var birthdate: Date? = nil
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "email"
    }
    
    func mapping(map: Map) {
        firstName <- map["firstname"]
        lastName <- map["lastname"]
        email <- map["email"]
        phone <- map["phone"]
        birthdate <- (map["birthdate"], DateTransform())
    }
}
