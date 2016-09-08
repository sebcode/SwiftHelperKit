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

    func waitFor(_ hasCalledBack: UnsafePointer<Bool>) -> Bool {
        let showProgress = CommandLine.arguments.contains("--progress")

        while hasCalledBack.pointee == false {
            if showProgress {
                print(".", terminator: "")
                fflush(__stdoutp)
            }
            let loopUntil = Date(timeIntervalSinceNow: 0.1)
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)
        }
        
        return true
    }

}
