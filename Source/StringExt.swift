//
//  StringExtensions.swift
//  SwiftHelperKit
//
//  Created by Sebastian Volland on 15/08/15.
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

public extension String {

    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    func trim(char: Character) -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: String(char)))
    }

    // http://stackoverflow.com/questions/26501276/convert-string-to-hex-string-in-swift/26502285#26502285
    func dataFromHexString() -> NSData? {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")

        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)
        let range = NSMakeRange(0, trimmedString.characters.count)
        let found = regex.firstMatchInString(trimmedString, options: .ReportProgress, range: range)
        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
            return nil
        }

        let data = NSMutableData(capacity: trimmedString.characters.count / 2)

        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
        }

        return data
    }

}
