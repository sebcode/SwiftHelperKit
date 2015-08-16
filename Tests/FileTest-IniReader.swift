//
//  FileTest-IniReader.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class FileTestIniReader: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testReadIni() {
        let tmpFile = try! File.createTemp()
        try! tmpFile.setContents("[a]\nb=c")

        XCTAssertTrue(try! tmpFile.readIni() == ["a" : ["b" : "c"]])
        try! tmpFile.delete()
    }

}
