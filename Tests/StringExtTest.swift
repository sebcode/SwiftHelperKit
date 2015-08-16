//
//  StringExtensionsTest.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class StringExtTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTrim() {
        XCTAssertEqual("", "         ".trim())
        XCTAssertEqual("a", "   a     ".trim())

        XCTAssertEqual("hallo", "/hallo/".trim("/"))
        XCTAssertEqual("hallo", "/hallo".trim("/"))
        XCTAssertEqual("hallo", "hallo/".trim("/"))
        XCTAssertEqual("hallo/test", "/hallo/test/".trim("/"))
    }

    func testDataFromHexadecimalString() {
        XCTAssertEqual("aabb0011", "AABB0011".dataFromHexString()!.hexString())
        XCTAssertEqual("aabb0011", "aabb0011".dataFromHexString()!.hexString())
        XCTAssertEqual("", "".dataFromHexString()!.hexString())

        XCTAssertTrue("zzz".dataFromHexString() == nil)
    }

}
