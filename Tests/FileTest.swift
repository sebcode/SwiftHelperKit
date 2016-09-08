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

        _ = file.deleteIfExists()
        try! file.create()
        XCTAssertTrue(file.exists)
        try! file.delete()

        do {
            _ = try File.create("")
            XCTFail()
        } catch { }

        do {
            _ = try File.create("/tmp")
            XCTFail()
        } catch { }
    }

    #if os(OSX)
    func testTrash() {
        let tmpFile = try! File.createTemp()
        XCTAssertTrue(tmpFile.exists)

        let trashedFile = tmpFile.trash()
        XCTAssertFalse(tmpFile.exists)
        XCTAssertTrue(trashedFile!.exists)

        XCTAssertTrue(trashedFile!.name.contains(".Trash"))
        _ = trashedFile!.deleteIfExists()
    }
    #endif

    func testProperties() {
        let tmpDir = try! Directory.createTemp()
        let tmpFile = tmpDir.file("testfile.txt")

        XCTAssertEqual(tmpFile.name, tmpFile.description)
        XCTAssertEqual("testfile", tmpFile.baseNameWithoutExtension)
        XCTAssertEqual("txt", tmpFile.fileExtension)
        XCTAssertEqual("testfile.txt", tmpFile.baseName)
        XCTAssertEqual("testfile.txt", tmpFile.displayName)
        XCTAssertEqual(tmpFile.name, tmpFile.url!.path)
        XCTAssertTrue((tmpFile.mtime?.timeIntervalSinceNow ?? 0) <= 3)
        XCTAssertTrue((tmpFile.ctime?.timeIntervalSinceNow ?? 0) <= 3)

        _ = tmpFile.deleteIfExists()
        _ = tmpDir.deleteIfExists()

        XCTAssertNil(tmpFile.ctime)
        XCTAssertNil(tmpFile.mtime)
    }

    #if os(OSX)
    func testIsSymlink() {
        XCTAssertFalse(File(name: "/tmp/doesnotexist").isSymlink)

        let tmpDir = try! Directory.createTemp()

        let tmpFile = tmpDir.file("testfile.txt")
        try! tmpFile.setContents("Hallo123")
        XCTAssertFalse(tmpFile.isSymlink)

        let tmpLinkFile = tmpDir.file("tmplinkfile")

        let task = Process()
        task.launchPath = "/bin/ln"
        task.arguments = [ "-s", tmpFile.name, tmpLinkFile.name ]
        task.launch()
        task.waitUntilExit()
        XCTAssertEqual(0, task.terminationStatus)

        XCTAssertTrue(tmpLinkFile.exists)
        XCTAssertTrue(tmpLinkFile.isSymlink)

        _ = tmpFile.deleteIfExists()
        _ = tmpLinkFile.deleteIfExists()
        _ = tmpDir.deleteIfExists()
    }
    #endif

    func testIsDirectory() {
        let tmpDir = try! Directory.createTemp()
        XCTAssertTrue(File(name: tmpDir.name).isDirectory)

        let tmpFile = tmpDir.file("testfile.txt")
        try! tmpFile.create()
        XCTAssertFalse(tmpFile.isDirectory)
        _ = tmpFile.deleteIfExists()

        XCTAssertFalse(File(name: "/tmp/doesnotexist").isDirectory)

        _ = tmpDir.deleteIfExists()
    }

    func testDirectory() {
        let tmpDir = try! Directory.createTemp()

        let tmpFile = tmpDir.file("testfile.txt")

        XCTAssertEqual(tmpFile.dirName, tmpDir.name)
        XCTAssertEqual(tmpFile.directory, tmpDir)

        _ = tmpDir.deleteIfExists()
    }

    func testCreateFromExisting() {
        let file = try! File.createTemp()
        let file2 = try! File.existing(file.name)
        XCTAssertEqual(file.name, file2.name)
        try! file.delete()

        do {
            _ = try File.existing(file.name)
            XCTFail()
        } catch { }
    }

    func testCreateFromExistingRealpath() {
        let tmpFile = try! File.createTemp()

        chdir(tmpFile.dirName)
        let file = try! File.existing(tmpFile.baseName)

        XCTAssertTrue(file.exists)
        XCTAssertEqual(tmpFile.name, file.name)

        _ = tmpFile.deleteIfExists()
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
            _ = try file.getContents()
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

    func testMove() {
        let tmpDir = try! Directory.createTemp()

        let srcFile = tmpDir.file("srcFile")
        try! srcFile.setContents("123")

        let destFile = tmpDir.file("destFile")
        try! srcFile.move(destFile)

        XCTAssertFalse(srcFile.exists)
        XCTAssertTrue(destFile.exists)
        XCTAssertEqual("123", try! destFile.getContents())

        _ = destFile.deleteIfExists()
        _ = tmpDir.deleteIfExists()
    }

    func testCopy() {
        let tmpDir = try! Directory.createTemp()

        let srcFile = tmpDir.file("srcFile")
        try! srcFile.setContents("123")

        let destFile = tmpDir.file("destFile")
        try! srcFile.copy(destFile)

        XCTAssertTrue(srcFile.exists)
        XCTAssertTrue(destFile.exists)
        XCTAssertEqual("123", try! destFile.getContents())

        _ = srcFile.deleteIfExists()
        _ = destFile.deleteIfExists()
        _ = tmpDir.deleteIfExists()
    }

    func testCopyRange() {
        let tmpDir = try! Directory.createTemp()

        let srcFile = tmpDir.file("srcFile")
        try! srcFile.setContents(".HALLO123.")

        let destFile = tmpDir.file("destFile")
        try! srcFile.copy(destFile, range: (1, 8))

        XCTAssertTrue(srcFile.exists)
        XCTAssertTrue(destFile.exists)
        XCTAssertEqual("HALLO123", try! destFile.getContents())

        _ = srcFile.deleteIfExists()
        _ = destFile.deleteIfExists()
        _ = tmpDir.deleteIfExists()
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

    func testAppendFileNotWriteable() {
        let tmpData = String(repeating: String(("a" as Character)), count: 1024 * 1024 * 15)

        let srcFile = try! File.createTemp()
        try! srcFile.setContents(tmpData)
        defer {
            _ = srcFile.deleteIfExists()
        }

        let destDir = Directory(name: "/Volumes/10MBTMP")
        let destFile = destDir.file("tmp123")

        do {
            try destFile.append(srcFile)
            defer {
                _ = destFile.deleteIfExists()
            }
            XCTFail()
        } catch {}
    }

// XXX How to catch "NSFileHandleOperationException", "*** -[NSConcreteFileHandle writeData:]: No space left on device" ?
//    func testAppendStringNotWriteable() {
//        let tmpData = String(count: 1024 * 1024 * 15, repeatedValue: ("a" as Character))
//
//        let destDir = Directory(name: "/Volumes/10MBTMP")
//        let destFile = destDir.file("tmp123")
//
//        do {
//            try destFile.append(tmpData)
//            defer {
//                destFile.deleteIfExists()
//            }
//            XCTFail()
//        } catch {}
//    }

    func testNameWithoutExtension() {
        let tmpDir = try! Directory.createTemp()

        var tmpFile = tmpDir.file("Hallo.txt")
        XCTAssertEqual(tmpDir.file("Hallo").name, tmpFile.nameWithoutExtension())
        XCTAssertEqual(tmpDir.file("Hallo").name, tmpFile.nameWithoutExtension("txt"))
        XCTAssertEqual(tmpDir.file("Hallo.txt").name, tmpFile.nameWithoutExtension("part"))
        _ = tmpFile.deleteIfExists()

        tmpFile = tmpDir.file("Hallo.txt.txt")
        XCTAssertEqual(tmpDir.file("Hallo.txt").name, tmpFile.nameWithoutExtension())
        XCTAssertEqual(tmpDir.file("Hallo.txt").name, tmpFile.nameWithoutExtension("txt"))
        XCTAssertEqual(tmpDir.file("Hallo.txt.txt").name, tmpFile.nameWithoutExtension("part"))
        _ = tmpFile.deleteIfExists()

        _ = tmpDir.deleteIfExists()
    }

    func testRelativeName() {
        let baseDir = Directory(name: "/tmp")

        XCTAssertEqual("wurst123", File(name: "/tmp/wurst123").relativeName(baseDir))
        XCTAssertEqual("wurst123/asdf", File(name: "/tmp/wurst123/asdf").relativeName(baseDir))
        XCTAssertEqual("/tmpx/wurst123/asdf", File(name: "/tmpx/wurst123/asdf").relativeName(baseDir))
    }

}
