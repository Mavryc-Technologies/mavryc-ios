//
//  databaseTests.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import XCTest
@testable import mavryc
import RealmSwift

class databaseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRealmSimpleWriteRead() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name

        let realm = try! Realm()
        
        let jsonData = "{\"email\": \"todd@lavamonster.io\", \"firstname\": \"Todd\", \"lastname\": \"Hop\"}".data(using: .utf8)!
        
        let object = try! JSONSerialization.jsonObject(with: jsonData) as! [String: String]
        
        try! realm.write {
            realm.create(User.self, value: object, update: true)
        }
        
        let expectedEmail = "todd@lavamonster.io"
        
        let retrievedUser = realm.objects(User.self).filter("email = %@",expectedEmail).first
        
        XCTAssertEqual(retrievedUser?.email, expectedEmail,
                       "User was not properly stored to and retrieved from Realm.")
    }
}
