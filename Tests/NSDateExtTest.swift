//
//  NSDateExtensions.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class NSDateExtTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCompare() {
        XCTAssertTrue(NSDate() > NSDate().dateByAddingTimeInterval(10))
        XCTAssertTrue(NSDate() < NSDate().dateByAddingTimeInterval(-10))
    }
    
}
