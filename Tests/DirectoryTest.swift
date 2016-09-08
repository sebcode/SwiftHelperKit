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

    func testParentDirectory() {
        var testDir = Directory(name: "/tmp")
        XCTAssertEqual("/", testDir.parentDirectory.name)

        testDir = Directory(name: "/notexists")
        XCTAssertEqual("/", testDir.parentDirectory.name)

        testDir = Directory(name: "/")
        XCTAssertEqual("/", testDir.parentDirectory.name)

        testDir = Directory(name: "/tmp/what/ever/")
        XCTAssertEqual("/tmp/what", testDir.parentDirectory.name)

        testDir = Directory(name: "/tmp/what/ever")
        XCTAssertEqual("/tmp/what", testDir.parentDirectory.name)
    }

    func testFindCommonDirectory() {
        var dirs: [Directory] = [
            Directory(name: "/tmp/asdf/a/b/c/d/fewfewfewew"),
            Directory(name: "/tmp/dev"),
            Directory(name: "/tmp/Movies"),
            Directory(name: "/tmp/Movies/bla"),
        ]
        XCTAssertEqual("/tmp", Directory.findCommonDirectory(dirs)!.name)

        dirs = [
            Directory(name: "/tmp/dev"),
            Directory(name: "/"),
        ]
        XCTAssertEqual("/", Directory.findCommonDirectory(dirs)!.name)

        dirs = [
            Directory(name: "/tmp/wurst/spaten/bla"),
            Directory(name: "/tmp/wurst/daten"),
        ]
        XCTAssertEqual("/tmp/wurst", Directory.findCommonDirectory(dirs)!.name)

        dirs = []
        XCTAssertNil(Directory.findCommonDirectory(dirs))

        dirs = [
            Directory(name: "/tmp/dev"),
        ]
        XCTAssertEqual("/tmp/dev", Directory.findCommonDirectory(dirs)!.name)
    }

    func testFiles() {
        let tmpDir = try! Directory.createTemp()

        var exp1 = [FilePath]()
        exp1 += [ tmpDir.file("Test1.txt") ]
        exp1 += [ tmpDir.file("Test2.txt") ]
        exp1 += [ tmpDir.file("Test3.txt") ]
        exp1 += [ tmpDir.subDirectory("Dir") ]
        exp1 += [ tmpDir.file("Dir/SubTest.txt") ]
        exp1 += [ tmpDir.subDirectory("Dir/Dir2") ]
        exp1 += [ tmpDir.file("Dir/Dir2/SubTest2.txt") ]
        exp1.forEach { try! $0.create() }
        exp1 = exp1.sorted { $0.name < $1.name }

        let ret = tmpDir.files().sorted { $0.name < $1.name }
        XCTAssertTrue(exp1 == ret)

        exp1.forEach { _ = $0.deleteIfExists() }
        _ = tmpDir.deleteIfExists()
        XCTAssertFalse(tmpDir.exists)
    }

    func testGlob() {
        let tmpDir = try! Directory.createTemp()

        var exp1 = [FilePath]()
        exp1 += [ tmpDir.file("Test1.txt") ]
        exp1 += [ tmpDir.file("Test2.txt") ]
        exp1 += [ tmpDir.file("Test3.txt") ]
        exp1.forEach { try! $0.create() }
        exp1 = exp1.sorted { $0.name < $1.name }

        var exp2 = [FilePath]()
        exp2 += [ tmpDir.file("Bla.dat") ]
        exp2.forEach { try! $0.create() }

        var exp3 = [FilePath]()
        exp3 += [ tmpDir.subDirectory("Hallo") ]
        exp3.forEach { try! $0.create() }

        var ret = try! tmpDir.glob("*.txt")!.sorted { $0.name < $1.name }
        XCTAssertTrue(exp1 == ret)

        ret = try! tmpDir.glob("*.dat")!
        XCTAssertTrue(exp2 == ret)

        var all = exp1 + exp2 + exp3
        all = all.sorted { $0.name < $1.name }
        ret = try! tmpDir.glob("*")!.sorted { $0.name < $1.name }
        XCTAssertTrue(all == ret)

        exp1.forEach { _ = $0.deleteIfExists() }
        exp2.forEach { _ = $0.deleteIfExists() }
        exp3.forEach { _ = $0.deleteIfExists() }
        _ = tmpDir.deleteIfExists()
        XCTAssertFalse(tmpDir.exists)
    }

    func testCreateTempFile() {
        let tmpDir = try! Directory.createTemp()

        let tmpFile = try! tmpDir.createTempFile()

        XCTAssertTrue(tmpFile.name.hasPrefix(tmpDir.name))

        _ = tmpFile.deleteIfExists()
        _ = tmpDir.deleteIfExists()
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

        _ = tmpDir.file("testfile (3).tmp").deleteIfExists()

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
        tmpFiles.forEach { _ = $0.deleteIfExists() }
        _ = tmpDir.deleteIfExists()
        XCTAssertFalse(tmpDir.exists)
    }

}
