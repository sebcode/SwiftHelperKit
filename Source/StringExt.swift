//
//  StringExtensions.swift
//  SwiftHelperKit
//
//  Created by Sebastian Volland on 15/08/15.
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

public extension String {

    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public func trim(_ char: Character) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: String(char)))
    }

    // Based on http://stackoverflow.com/a/17511588/503326
    func dataFromHexString() -> Data? {
        let str = self
        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
        let range = NSMakeRange(0, str.characters.count)
        let found = regex.firstMatch(in: str, options: .reportProgress, range: range)
        if found == nil || found?.range.location == NSNotFound || str.characters.count % 2 != 0 {
            return nil
        }

        let _str = NSString(string: str)
        let len = _str.length
        let data = NSMutableData(capacity: len / 2)

        var i = 0
        var byteChars: [CChar] = [0, 0, 0]
        var wholeByte: UInt32 = 0

        while i < len {
            byteChars[0] = _str.substring(with: NSMakeRange(i, 1)).cString(using: String.Encoding.utf8)![0]
            i += 1
            byteChars[1] = _str.substring(with: NSMakeRange(i, 1)).cString(using: String.Encoding.utf8)![0]
            i += 1
            wholeByte = UInt32(strtoul(byteChars, nil, 16))
            data?.append(&wholeByte, length: 1)
        }
        
        return data as Data?
    }

}
