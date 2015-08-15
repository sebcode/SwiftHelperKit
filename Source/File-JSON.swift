//
//  File.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

// File Extension for SwiftyJSON

import SwiftyJSON

extension File {

    public func readJSON() throws -> JSON {
        guard let data = File.manager.contentsAtPath(name) else {
            throw FileError.FileNotReadable(file: name)
        }

        var jsonError: NSError? = nil
        let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
        guard jsonError == nil else {
            throw jsonError!
        }

        return json
    }

    public func writeJSON(json: JSON) throws {
        let data = try json.rawData(options: .PrettyPrinted)
        if let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
            try setContents(str)
        }
    }
    
}
