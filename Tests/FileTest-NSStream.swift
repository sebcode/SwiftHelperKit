//
//  FileTest-NSStream.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation
@testable import SwiftHelperKit

import XCTest

class FileTestNSStream: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetInputStream() {
        var file = try! File.createTemp()
        _ = try! file.getInputStream()
        try! file.delete()

        file = File(name: "")
        do {
            _ = try file.getInputStream()
            XCTFail()
        } catch { }
    }

    func testGetOutputStream() {
        var file = try! File.createTemp()
        _ = try! file.getOutputStream(true)
        try! file.delete()

        file = File(name: "")
        do {
            _ = try file.getOutputStream(true)
            XCTFail()
        } catch { }
    }

}
