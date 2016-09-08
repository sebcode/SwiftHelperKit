//
//  NSColorExtTest.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class NSColorExtTest: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testColor() {
        let rgb = NSColorSpace.sRGB

        var color = NSColor(rgba: "#000000").usingColorSpace(rgb)
        XCTAssertEqual(color, NSColor.black.usingColorSpace(rgb))

        color = NSColor(rgba: "#ffffff").usingColorSpace(rgb)
        XCTAssertEqual(color, NSColor.white.usingColorSpace(rgb))
    }
    
}
