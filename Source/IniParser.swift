//
//  IniParser.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

public class IniParser {

    public class func parse(string string: String) -> [String: [String: String]] {
        guard string != "" else {
            return [:]
        }

        let lines = string.componentsSeparatedByString("\n") as [String]
        var currentSectionName = ""
        var currentSection: [String: String] = [:]
        var ret: [String: [String: String]] = [:]

        for line in lines {
            if line.hasPrefix("[") {
                if currentSectionName != "" {
                    ret[currentSectionName] = currentSection
                    currentSection = [:]
                }
                currentSectionName = line.substringWithRange(line.startIndex.advancedBy(1)..<line.endIndex.advancedBy(-1))
            }

            if line != "" && currentSectionName != "" {
                if let range = line.rangeOfString("=") {
                    let key = line.substringToIndex(range.startIndex).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    let value = line.substringFromIndex(range.endIndex).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    currentSection[key] = value
                }
            }
        }
        if currentSectionName != "" {
            ret[currentSectionName] = currentSection
        }

        return ret
    }

}
