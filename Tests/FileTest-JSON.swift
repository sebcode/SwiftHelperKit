//
//  FileTest-JSON.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class FileTestJSON: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testReadJSON() {
        let file = try! File.createTemp()
        try! file.setContents("[ 1, 2, 3 ]")

        let json = try! file.readJSON()
        XCTAssertEqual(3, json[2].intValue)

        try! file.setContents("{")
        do {
            try file.readJSON()
            XCTFail()
        } catch { }

        try! file.delete()
    }

}
