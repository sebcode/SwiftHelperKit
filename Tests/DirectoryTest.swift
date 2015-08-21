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

    func testCreateTempFile() {
        let tmpDir = try! Directory.createTemp()

        let tmpFile = try! tmpDir.createTempFile()

        XCTAssertTrue(tmpFile.name.hasPrefix(tmpDir.name))

        tmpFile.deleteIfExists()
        tmpDir.deleteIfExists()
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

        // With appendix

        newFile = tmpDir.nextNewFile("testfile", appendix: "part")!
        XCTAssertEqual(tmpDir.file("testfile.part").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile", appendix: "part")!
        XCTAssertEqual(tmpDir.file("testfile (2).part").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.txt", appendix: "part")!
        XCTAssertEqual(tmpDir.file("testfile.txt.part").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile.txt", appendix: "part")!
        XCTAssertEqual(tmpDir.file("testfile (2).txt.part").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile2.part", appendix: "part")!
        XCTAssertEqual(tmpDir.file("testfile2.part.part").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile2.part", appendix: "part")!
        XCTAssertEqual(tmpDir.file("testfile2 (2).part.part").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        newFile = tmpDir.nextNewFile("testfile2.part", appendix: "part")!
        XCTAssertEqual(tmpDir.file("testfile2 (3).part.part").name, newFile.name)
        try! newFile.create()
        tmpFiles += [ newFile ]

        // Cleanup
        tmpFiles.forEach { $0.deleteIfExists() }
        tmpDir.deleteIfExists()
        XCTAssertFalse(tmpDir.exists)
    }

}
