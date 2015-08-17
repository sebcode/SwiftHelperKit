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
        let rgb = NSColorSpace.sRGBColorSpace()

        var color = NSColor(rgba: "#000000").colorUsingColorSpace(rgb)
        XCTAssertEqual(color, NSColor.blackColor().colorUsingColorSpace(rgb))

        color = NSColor(rgba: "#ffffff").colorUsingColorSpace(rgb)
        XCTAssertEqual(color, NSColor.whiteColor().colorUsingColorSpace(rgb))
    }
    
}
