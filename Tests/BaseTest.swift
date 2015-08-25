//
//  BaseTest.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest

class BaseTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func waitFor(hasCalledBack: UnsafePointer<Bool>) -> Bool {
        let showProgress = Process.arguments.contains("--progress")

        while hasCalledBack.memory == false {
            if showProgress {
                print(".", terminator: "")
                fflush(__stdoutp)
            }
            let loopUntil = NSDate(timeIntervalSinceNow: 0.1)
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: loopUntil)
        }
        
        return true
    }

}
