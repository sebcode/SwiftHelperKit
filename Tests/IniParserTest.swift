//
//  IniParserTest.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class IniParserTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testParse() {
        let data = "[credentials]\n"
            + "access_key = access123\n"
            + "secret = secret123\n"
            + "\n"
            + "[config]\n"
            + "\n"
            + "data = 1\n"
            + "test = 2\n"

        let ret = IniParser.parse(string: data)

        XCTAssertEqual(2, ret.count)
        XCTAssertEqual(2, ret["config"]!.count)
        XCTAssertEqual(2, ret["credentials"]!.count)

        if let credentials = ret["credentials"] {
            XCTAssertEqual("access123", credentials["access_key"]!)
            XCTAssertEqual("secret123", credentials["secret"]!)
        }
    }

}
