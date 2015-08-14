//
//  FileTests.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class FileTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCreateAndDelete() {
        let file = try! File.create("/tmp/justatestfile")
        XCTAssertTrue(file.exists)
        XCTAssertEqual("/tmp/justatestfile", file.name)
        try! file.delete()

        do {
            try file.delete()
            XCTFail()
        } catch { }

        file.deleteIfExists()
        try! file.create()
        XCTAssertTrue(file.exists)
        try! file.delete()

        do {
            try File.create("")
            XCTFail()
        } catch { }

        do {
            try File.create("/tmp")
            XCTFail()
        } catch { }
    }

    func testSetAndGetContents() {
        let file = try! File.createTemp()
        XCTAssertTrue(file.exists)

        XCTAssertEqual("", try! file.getContents())
        XCTAssertEqual(0, file.size)
        try! file.setContents("hallo123")
        XCTAssertEqual("hallo123", try! file.getContents())
        XCTAssertEqual(8, file.size)

        try! file.delete()
        XCTAssertFalse(file.exists)
        XCTAssertEqual(0, file.size)
        do {
            try file.getContents()
            XCTFail()
        } catch { }
    }

    func testCheckExists() {
        let file = try! File.createTemp()
        try! file.checkExists()
        try! file.delete()

        do {
            try file.checkExists()
            XCTFail()
        } catch { }
    }

    func testTruncate() {
        let file = try! File.createTemp()

        try! file.setContents("hallo123")
        XCTAssertEqual(8, file.size)

        try! file.truncate(5)
        XCTAssertEqual("hallo", try! file.getContents())
        XCTAssertEqual(5, file.size)

        try! file.truncate(0)
        XCTAssertEqual("", try! file.getContents())
        XCTAssertEqual(0, file.size)

        try! file.delete()
    }

    func testAppend() {
        let destFile = try! File.createTemp()
        try! destFile.setContents("hallo123")

        let srcFile = try! File.createTemp()
        try! srcFile.setContents("destbytes")

        try! destFile.append(srcFile)

        XCTAssertEqual("hallo123destbytes", try! destFile.getContents())
        
        try! srcFile.delete()
    }
    
}
