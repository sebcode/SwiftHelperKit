//
//  File-Temp.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

// File Extension to create temp files

import Foundation

extension FilePath {

    public static func createTemp(prefix: String = "tmp") throws -> Self {
        let uuid: CFUUIDRef = CFUUIDCreate(nil)
        let uuidString = CFUUIDCreateString(nil, uuid)
        let name = NSString(string: NSTemporaryDirectory()).stringByAppendingPathComponent("\(prefix)-\(uuidString)")
        let file = self.init(name: name)
        try file.create()
        return file
    }

}
