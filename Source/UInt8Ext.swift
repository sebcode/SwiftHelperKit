//
//  UInt8Ext.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

// https://github.com/brentdax/SwiftDigest/blob/master/SwiftDigest/Utility.swift
extension UInt8 {
    static let allHexits: [Character] = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]

    public func toHex() -> String {
        let nybbles = [ self >> 4, self & 0x0F ]
        let hexits = nybbles.map() { nybble in UInt8.allHexits[Int(nybble)] }
        return String(hexits)
    }
}
