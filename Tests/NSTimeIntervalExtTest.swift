//
//  NSTimeIntervalExtensionsTest.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class NSTimeIntervalExtTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFormatTimeLeft() {
        var d: NSTimeInterval = NSTimeInterval(-1)
        XCTAssertNil(d.formatTimeLeft)

        d = NSTimeInterval(59)
        XCTAssertEqual("a few seconds", d.formatTimeLeft!)

        d = NSTimeInterval(1)
        XCTAssertEqual("a few seconds", d.formatTimeLeft!)

        d = NSTimeInterval(1 * 60)
        XCTAssertEqual("1 minute", d.formatTimeLeft!)

        d = NSTimeInterval(2 * 60)
        XCTAssertEqual("2 minutes", d.formatTimeLeft!)

        d = NSTimeInterval(1 * 60 * 60)
        XCTAssertEqual("1 hour", d.formatTimeLeft!)

        d = NSTimeInterval(2 * 60 * 60)
        XCTAssertEqual("2 hours", d.formatTimeLeft!)
        
        d = NSTimeInterval(100 * 60 * 60)
        XCTAssertEqual("100 hours", d.formatTimeLeft!)

        d = NSTimeInterval(-1)
        XCTAssertTrue(d.formatTimeLeft == nil)

        d = NSTimeInterval(Double.NaN)
        XCTAssertTrue(d.formatTimeLeft == nil)
    }

}
