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

    public func getInputStream() throws -> NSInputStream {
        guard let inputStream = NSInputStream(fileAtPath: name) else {
            throw FileError.FileNotReadable(file: name)
        }

        return inputStream
    }

    public func getOutputStream(append: Bool) throws -> NSOutputStream {
        guard let outputStream = NSOutputStream(toFileAtPath: name, append: append) else {
            throw FileError.FileNotWriteable(file: name)
        }

        return outputStream
    }

}
