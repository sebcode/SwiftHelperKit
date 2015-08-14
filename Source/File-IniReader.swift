//
//  File-IniReader.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

extension File {

    public func readIni() throws -> [String: [String: String]] {
        let contents = try getContents()
        return IniParser.parse(string: String(contents))
    }

}
