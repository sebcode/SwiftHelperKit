//
//  ExceptionCatcher.swift
//  SwiftHelperKit
//
//  Created by Sebastian Volland on 24.03.18.
//  Copyright © 2018 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class ExceptionCatcherTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCatch() {
        let file = try! File.createTemp()
        try! file.setContents("test")
        let exception = tryBlock {
            let fileHandle = FileHandle(forReadingAtPath: file.name)!
            fileHandle.write("asdf".data(using: .utf8)!)
        }
        guard exception != nil else {
            XCTFail()
            return
        }
        try! file.delete()
    }

}
