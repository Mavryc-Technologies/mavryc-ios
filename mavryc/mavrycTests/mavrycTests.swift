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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCitySearchAutoCompletionSuggestions() {
        let exp = expectation(description: "test autocompletion")
        let citySource = Cities.shared
        citySource.autoCompletionSuggestions(for: "Pho", predictions: { list in
            list.forEach({ (item) in
                print("autocompletion suggestion: \(item)")
            })
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 5.0, handler:nil)
    }
    
}
