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
        guard let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            return ""
        }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { CC_SHA256($0, CC_LONG(data.count), &hash) }
        return hash.map { byte in byte.toHex() }.reduce("", +)
    }

}
