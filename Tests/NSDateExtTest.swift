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
        let date = Date()
        XCTAssertTrue(date == date)

        let copyDate = date.addingTimeInterval(1).addingTimeInterval(-1)
        XCTAssertTrue(date == copyDate)

        XCTAssertTrue(Date() < Date().addingTimeInterval(10))
        XCTAssertTrue(Date() > Date().addingTimeInterval(-10))
    }
    
}
