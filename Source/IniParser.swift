//
//  IniParser.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

open class IniParser {

    open class func parse(string: String) -> [String: [String: String]] {
        guard string != "" else {
            return [:]
        }

        let lines = string.components(separatedBy: "\n") as [String]
        var currentSectionName = ""
        var currentSection: [String: String] = [:]
        var ret: [String: [String: String]] = [:]

        for line in lines {
            if line.hasPrefix("[") {
                if currentSectionName != "" {
                    ret[currentSectionName] = currentSection
                    currentSection = [:]
                }
                currentSectionName = String(line[line.index(line.startIndex, offsetBy: 1)..<line.index(line.endIndex, offsetBy: -1)])
            }

            if line != "" && currentSectionName != "" {
                if let range = line.range(of: "=") {
                    let key = line[..<range.lowerBound].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let value = String(line.suffix(from: range.upperBound)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
