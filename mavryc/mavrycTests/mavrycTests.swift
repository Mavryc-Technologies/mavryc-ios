//
//  mavrycTests.swift
//  mavrycTests
//
//  Created by Todd Hopkinson on 4/1/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import XCTest
@testable import mavryc
import SwiftyJSON

class mavrycTests: XCTestCase {
    
    var globalTempUserEmail: String = "h@h.com"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearchForUser() {
        
        let exp = expectation(description: "test web service find-user expectation")
        
        UserSearchClient().makeRequest(email: globalTempUserEmail, success: { responseString in
            print("serverResponse: \(responseString)")
            exp.fulfill()
        }, failure: { error in
            XCTFail()
        })
        
        waitForExpectations(timeout: 20.0, handler:nil)
    }
    
}
