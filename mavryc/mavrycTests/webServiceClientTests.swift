//
//  webServiceClientTests.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import XCTest
@testable import mavryc
import SwiftyJSON

class webServiceClientTests: XCTestCase {
    
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
        
        let email = "h@h.com"
        //        let email = "one@test.com"
        FetchUserClient().makeRequest(email: email, success: { responseString in
            print("serverResponse: \(responseString)")
            exp.fulfill()
        }, failure: { error in
            XCTFail()
        })
        
        waitForExpectations(timeout: 20.0, handler:nil)
    }
    
    func testSignup() {
        let exp = expectation(description: "signup web service expectation")
        let dto = SignupDTO(email: "five@test.com", firstName: "oneF", lastName: "oneL", password: "password")
        SignupClient().makeRequest(signup: dto, success: { responseString in
            print("serverResponse: \(responseString)")
            exp.fulfill()
        }, failure: { error in
            XCTFail()
        })
        
        waitForExpectations(timeout: 20.0, handler:nil)
    }
    
    func testLogin() {
        let exp = expectation(description: "Login Web Service expectation")
        let dto = LoginDTO(email: "ScoobyDoo@aol.com", password: "ScoobySnacks")
        LoginClient().makeLoginRequest(login: dto, success: { responseString in
            print("serverResponse: \(responseString)")
            exp.fulfill()
        }, failure: { error in
            XCTFail()
        })
    
    }
    
    func testFetchFlightsClient() {
        let exp = expectation(description: "fetch flights web service expectation")

        let dto = FetchFlightsDTO()
        FetchFlightsClient().makeRequest(dto: dto, success: { flights in
            print("flights: \(flights)")
            exp.fulfill()
        }, failure: { error in
            XCTFail()
        })
        
        waitForExpectations(timeout: 20.0, handler:nil)
    }
    
}
