//
//  FileTest-Temp.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class FileTestTemp: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCreateTempFile() {
        let file = try! File.createTemp()
        XCTAssertTrue(file.exists)
    #if os(iOS)
        XCTAssertTrue(file.name.rangeOfString("/tmp/") != nil)
    #elseif os(OSX)
        XCTAssertTrue(file.name.hasPrefix("/var/"))
    #endif
        try! file.delete()
        XCTAssertFalse(file.exists)
    }

}
