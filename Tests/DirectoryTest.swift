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

    func testGlob() {
        let tmpDir = try! Directory.createTemp()

        var exp1 = [FilePath]()
        exp1 += [ tmpDir.file("Test1.txt") ]
        exp1 += [ tmpDir.file("Test2.txt") ]
        exp1 += [ tmpDir.file("Test3.txt") ]
        exp1.forEach { try! $0.create() }
        exp1 = exp1.sort { $0.name < $1.name }

        var exp2 = [FilePath]()
        exp2 += [ tmpDir.file("Bla.dat") ]
        exp2.forEach { try! $0.create() }

        var exp3 = [FilePath]()
        exp3 += [ tmpDir.subDirectory("Hallo") ]
        exp3.forEach { try! $0.create() }

        var ret = try! tmpDir.glob("*.txt")!.sort { $0.name < $1.name }
        XCTAssertTrue(exp1 == ret)

        ret = try! tmpDir.glob("*.dat")!
        XCTAssertTrue(exp2 == ret)

        var all = exp1 + exp2 + exp3
        all = all.sort { $0.name < $1.name }
        ret = try! tmpDir.glob("*")!.sort { $0.name < $1.name }
        XCTAssertTrue(all == ret)

        exp1.forEach { $0.deleteIfExists() }
        exp2.forEach { $0.deleteIfExists() }
        exp3.forEach { $0.deleteIfExists() }
        tmpDir.deleteIfExists()
        XCTAssertFalse(tmpDir.exists)
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
