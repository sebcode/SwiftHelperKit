//
//  StringExt-SHA256.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class StringExtTestSHA256: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSha256sum() {
        XCTAssertEqual("ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae", "test123".sha256sum())
    }

}
