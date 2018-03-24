//
//  FileTest-SHA256.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class FileTestSHA256: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testComputeSHA256() {
        let file = try! File.createTemp()
        try! file.setContents("hallo123")
        XCTAssertEqual("f0c3cd6fc4b23eae95e39de1943792f62ccefd837158b69c63aebaf3041ed345", try! file.computeSHA256())
        try! file.delete()
    }

    func testComputeSHA256Range() {
        let file1 = try! File.createTemp()
        try! file1.setContents("hallo123")
        XCTAssertEqual("f0c3cd6fc4b23eae95e39de1943792f62ccefd837158b69c63aebaf3041ed345", try! file1.computeSHA256())
        try! file1.delete()

        let file2 = try! File.createTemp()
        try! file2.setContents("test123")
        XCTAssertEqual("ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae", try! file2.computeSHA256())
        try! file2.delete()

        let file = try! File.createTemp()
        try! file.setContents("hallo123test123xxx")
        XCTAssertEqual("f0c3cd6fc4b23eae95e39de1943792f62ccefd837158b69c63aebaf3041ed345", try! file.computeSHA256((from: 0, to: 7)))
        XCTAssertEqual("ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae", try! file.computeSHA256((from: 8, to: 14)))
        try! file.delete()
    }

    func testComputeSHA256RangeFail() {
//        let task = Process()
//        let pipe = Pipe()
//        task.launchPath = "/usr/bin/mkfifo"
//        task.arguments = ["/tmp/testpipe"]
//        task.standardOutput = pipe
//        task.launch()

//        let exception = tryBlock {
//            let fileHandle = FileHandle(forReadingAtPath: "/tmp/test123")!
//            fileHandle.write("wurst".data(using: .utf8)!)
//        }
//        guard exception != nil else {
//            XCTFail()
//            return
//        }


//        let file4 = File(name: "/tmp/testinvalid")
//        //        do {
//        _ = try! file4.computeSHA256((from: 1, to: 10))
//        //            XCTFail()
//        //        } catch { }
    }

}
