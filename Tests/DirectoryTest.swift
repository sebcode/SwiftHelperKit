//
//  DirectoryTest.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class DirectoryTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNextNewFile() {
        let tmpDir = try! Directory.createTemp()
        var tmpFiles = [File]()

        var newFile = tmpDir.nextNewFile("testfile")!
        XCTAssertEqual(tmpDir.file("testfile").name, newFile.name)

        newFile = tmpDir.nextNewFile("testfile.tmp")!
        XCTAssertEqual(tmpDir.file("testfile.tmp").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.tmp")!
        XCTAssertEqual(tmpDir.file("testfile (2).tmp").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.tmp")!
        XCTAssertEqual(tmpDir.file("testfile (3).tmp").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.tmp")!
        XCTAssertEqual(tmpDir.file("testfile (4).tmp").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.tmp")!
        XCTAssertEqual(tmpDir.file("testfile (5).tmp").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        tmpDir.file("testfile (3).tmp").deleteIfExists()

        newFile = tmpDir.nextNewFile("testfile.tmp")!
        XCTAssertEqual(tmpDir.file("testfile (3).tmp").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile")!
        XCTAssertEqual(tmpDir.file("testfile").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile")!
        XCTAssertEqual(tmpDir.file("testfile (2)").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.tmp.txt")!
        XCTAssertEqual(tmpDir.file("testfile.tmp.txt").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.tmp.txt")!
        XCTAssertEqual(tmpDir.file("testfile.tmp (2).txt").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        tmpFiles.forEach { $0.deleteIfExists() }
        tmpDir.deleteIfExists()
        XCTAssertFalse(tmpDir.exists)
    }

}
