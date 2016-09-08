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
                currentSectionName = line.substring(with: line.characters.index(line.startIndex, offsetBy: 1)..<line.characters.index(line.endIndex, offsetBy: -1))
            }

            if line != "" && currentSectionName != "" {
                if let range = line.range(of: "=") {
                    let key = line.substring(to: range.lowerBound).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let value = line.substring(from: range.upperBound).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
