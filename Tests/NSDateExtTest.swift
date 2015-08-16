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
        let date = NSDate()
        XCTAssertTrue(date == date)

        let copyDate = date.dateByAddingTimeInterval(1).dateByAddingTimeInterval(-1)
        XCTAssertTrue(date == copyDate)

        XCTAssertTrue(NSDate() < NSDate().dateByAddingTimeInterval(10))
        XCTAssertTrue(NSDate() > NSDate().dateByAddingTimeInterval(-10))
    }
    
}
