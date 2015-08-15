//
//  StringExt-SHA256.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation
import CommonCrypto

public extension String {

    public func sha256sum() -> String {
        guard let data = (self as NSString).dataUsingEncoding(NSUTF8StringEncoding) else {
            return ""
        }

        var hash: [UInt8] = Array(count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash);
        return hash.map { byte in byte.toHex() }.reduce("", combine: +)
    }
    
}
