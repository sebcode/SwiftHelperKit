//
//  File-Stream.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

// File Extension for NSStream

import Foundation

extension File {

    // MARK: Convenience getters

    public func getInputStream() throws -> InputStream {
        guard let inputStream = InputStream(fileAtPath: name) else {
            throw FileError.fileNotReadable(file: name)
        }

        return inputStream
    }

    public func getOutputStream(_ append: Bool) throws -> OutputStream {
        guard let outputStream = OutputStream(toFileAtPath: name, append: append) else {
            throw FileError.fileNotWriteable(file: name)
        }

        return outputStream
    }

}
