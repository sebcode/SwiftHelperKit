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
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    public func trim(char: Character) -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: String(char)))
    }

    // Based on http://stackoverflow.com/a/17511588/503326
    func dataFromHexString() -> NSData? {
        let str = self
        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)
        let range = NSMakeRange(0, str.characters.count)
        let found = regex.firstMatchInString(str, options: .ReportProgress, range: range)
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
            byteChars[0] = _str.substringWithRange(NSMakeRange(i, 1)).cStringUsingEncoding(NSUTF8StringEncoding)![0]
            i += 1
            byteChars[1] = _str.substringWithRange(NSMakeRange(i, 1)).cStringUsingEncoding(NSUTF8StringEncoding)![0]
            i += 1
            wholeByte = UInt32(strtoul(byteChars, nil, 16))
            data?.appendBytes(&wholeByte, length: 1)
        }
        
        return data
    }

}
