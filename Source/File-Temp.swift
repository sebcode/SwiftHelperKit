//
//  File-Temp.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

// File Extension to create temp files

import Foundation

extension FilePath {

    public static func createTemp(_ prefix: String = "tmp") throws -> Self {
        let tmpFile = Directory.tempDirectory().file("\(prefix)-\(UUID().uuidString)")
        let new = self.init(name: tmpFile.name)
        try new.create()
        return new
    }

}
