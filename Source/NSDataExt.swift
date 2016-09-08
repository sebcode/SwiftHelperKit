//
//  NSDataExtensions.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

public extension Data {

    // http://stackoverflow.com/questions/26501276/convert-string-to-hex-string-in-swift/26502285#26502285
    public func hexString() -> String {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)

        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }

        return NSString(string: hexString) as String
    }

}
