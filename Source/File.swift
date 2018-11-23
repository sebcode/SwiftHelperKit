//
//  File.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

// MARK: Error types

public enum FileError: Error {
    case fileNotFound(file: String)
    case fileNotReadable(file: String)
    case fileNotWriteable(file: String)
}

extension FileError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fileNotFound(let file):
            return "File not found: \(file)"
        case .fileNotReadable(let file):
            return "File not readable: \(file)"
        case .fileNotWriteable(let file):
            return "File not writeable: \(file)"
        }
    }
}

// MARK: Base class

public func ==(lhs: FilePath, rhs: FilePath) -> Bool {
    return lhs.name == rhs.name
}

/**
    Common base class for `File` and `Directory`.
    Should not be used directly.
*/
open class FilePath: CustomStringConvertible, Equatable {

    static let manager = FileManager.default

    public let name: String
    
    // MARK: Initializers

    public required init(name: String) {
        self.name = NSString(string: name).standardizingPath
    }

    open class func create(_ name: String) throws -> Self {
        let file = self.init(name: name)
        try file.create()
        return file
    }

    open class func existing(_ name: String) throws -> Self {
        let pname = NSString(string: name).utf8String
        let resolved = realpath(pname, nil)
        guard resolved != nil else {
            throw FileError.fileNotFound(file: name)
        }
        guard let resolvedPath = String(validatingUTF8: resolved!) else {
            throw FileError.fileNotFound(file: name)
        }

        let file = self.init(name: resolvedPath)
        try file.checkExists()
        return file
    }

    // MARK: Convenience properties

    open var description: String {
        return name
    }

    open var url: URL? {
        return URL(fileURLWithPath: name)
    }

    open var baseName: String {
        return NSString(string: name).lastPathComponent
    }

    open var baseNameWithoutExtension: String {
        return NSString(string: baseName).deletingPathExtension
    }

    open var fileExtension: String {
        return NSString(string: name).pathExtension
    }

    open var exists: Bool {
        return FilePath.manager.fileExists(atPath: name)
    }

    open func checkExists() throws {
        if !exists {
            throw FileError.fileNotFound(file: name)
        }
    }

    open var displayName: String {
        return FilePath.manager.displayName(atPath: name)
    }

    open var mtime: Date? {
        do {
            let attr: NSDictionary = try FilePath.manager.attributesOfItem(atPath: name) as NSDictionary
            return attr.fileModificationDate()
        } catch {
            return nil
        }
    }

    open var ctime: Date? {
        do {
            let attr: NSDictionary = try FilePath.manager.attributesOfItem(atPath: name) as NSDictionary
            return attr.fileCreationDate()
        } catch {
            return nil
        }
    }

    open var isSymlink: Bool {
        guard let dirUrl = url else { return false }

        do {
            let properties = try (dirUrl as NSURL).resourceValues(forKeys: [URLResourceKey.isSymbolicLinkKey])
            guard let isSymlinkNumber = properties[URLResourceKey.isSymbolicLinkKey] as? NSNumber else { return false }
            return isSymlinkNumber.boolValue
        } catch _ {
            return false
        }
    }

    open var isDirectory: Bool {
        guard let dirUrl = url else { return false }

        do {
            let properties = try (dirUrl as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            guard let isDirNumber = properties[URLResourceKey.isDirectoryKey] as? NSNumber else { return false }
            return isDirNumber.boolValue
        } catch _ {
            return false
        }
    }

    // MARK: Convenience functions

    open func nameWithoutExtension(_ ext: String = "") -> String {
        if ext == "" || NSString(string: name).pathExtension == ext {
            return NSString(string: name).deletingPathExtension
        }

        return name
    }

    open func relativeName(_ baseDirectory: Directory) -> String {
        if name.hasPrefix(baseDirectory.name + "/") {
            if let range = baseDirectory.name.range(of: baseDirectory.name) {
                return String(name.suffix(from: range.upperBound)).trim("/")
            }
        }

        return name
    }

    // MARK: Write operations

    open func create() throws {
        // Abstract
    }

    // MARK: Delete operations

    open func delete() throws {
        try FilePath.manager.removeItem(atPath: name)
    }

    open func deleteIfExists() -> Bool {
        do {
            try delete()
            return true
        } catch {
            return false
        }
    }

    #if os(OSX)
    open func trash() -> File? {
        guard let trashUrl = url else {
            return nil
        }

        do {
            var resultUrl: NSURL?
            try File.manager.trashItem(at: trashUrl, resultingItemURL: &resultUrl)
            guard let newPath = resultUrl?.path else {
                return nil
            }

            return File(name: newPath)
        } catch {
            return nil
        }
    }
    #endif

}

// MARK: File class

/**
    `File` is a wrapper class for a file system file.
*/
open class File: FilePath {

    // MARK: Convenience properties

    open var size: Int64 {
        do {
            let attr: NSDictionary = try File.manager.attributesOfItem(atPath: name) as NSDictionary
            return Int64(attr.fileSize())
        } catch {
            return 0
        }
    }

    open var dirName: String {
        return NSString(string: name).deletingLastPathComponent
    }

    open var directory: Directory {
        return Directory(name: dirName)
    }

    // MARK: Write operations

    open override func create() throws {
        if !File.manager.createFile(atPath: name, contents: nil, attributes: nil) {
            throw FileError.fileNotWriteable(file: name)
        }
    }

    open func move(_ destFile: File) throws {
        do {
            try File.manager.moveItem(atPath: name, toPath: destFile.name)
        } catch {
            throw FileError.fileNotWriteable(file: destFile.name)
        }
    }

    open func copy(_ destFile: File) throws {
        do {
            try File.manager.copyItem(atPath: name, toPath: destFile.name)
        } catch {
            throw FileError.fileNotWriteable(file: destFile.name)
        }
    }

    open func copy(_ destFile: File, range:(from: Int64, to: Int64)) throws {
        let expectedTotalBytes: Int64 = range.to - range.from + 1

        guard exists else {
            throw FileError.fileNotReadable(file: name)
        }

        guard size > 0 else {
            if expectedTotalBytes > 0 {
                throw FileError.fileNotReadable(file: name)
            }

            try destFile.setContents("")
            return
        }

        var throwError: Error? = nil

        let exception = tryBlock {
            guard let readHandle = FileHandle(forReadingAtPath: self.name) else {
                throwError = FileError.fileNotReadable(file: self.name)
                return
            }

            if !destFile.exists {
                do {
                    try destFile.setContents("")
                } catch  {
                    throwError = FileError.fileNotWriteable(file: destFile.name)
                    return
                }
            }

            guard let writeHandle = FileHandle(forWritingAtPath: destFile.name) else {
                throwError = FileError.fileNotWriteable(file: destFile.name)
                return
            }

            readHandle.seek(toFileOffset: UInt64(range.from))

            let bufSize: Int64 = 1024 * 1024
            var bytesLeft: Int64 = range.to - range.from + 1
            var bytesReadTotal: Int64 = 0

            repeat {
                var readBytes: Int64 = bufSize
                if bytesLeft < readBytes {
                    readBytes = bytesLeft
                }
                var didRead = 0
                autoreleasepool {
                    let buf = readHandle.readData(ofLength: Int(readBytes))
                    didRead = buf.count
                    if buf.count > 0 {
                        writeHandle.write(buf)
                        bytesLeft -= Int64(buf.count)
                        bytesReadTotal += Int64(buf.count)
                    }
                }
                if didRead == 0 {
                    break
                }
            } while bytesLeft > 0

            if bytesReadTotal != expectedTotalBytes {
                throwError = FileError.fileNotReadable(file: self.name)
                return
            }

            readHandle.closeFile()
            writeHandle.closeFile()
        }

        if let err = throwError {
            throw err
        }

        guard exception == nil else {
            throw FileError.fileNotWriteable(file: destFile.name)
        }
    }

    open func truncate(_ size: Int64) throws {
        var throwError: Error? = nil

        let exception = tryBlock {
            guard let handle = FileHandle(forWritingAtPath: self.name) else {
                throwError = FileError.fileNotFound(file: self.name)
                return
            }

            handle.truncateFile(atOffset: UInt64(size))
        }

        if let err = throwError {
            throw err
        }

        guard exception == nil else {
            throw FileError.fileNotWriteable(file: self.name)
        }
    }

    open func setContents(_ contents: String) throws {
        guard let data = contents.data(using: String.Encoding.utf8) else {
            return
        }

        if File.manager.createFile(atPath: name, contents: data, attributes: nil) == false {
            throw FileError.fileNotWriteable(file: name)
        }
    }

    open func append(_ string: String) throws {
        var throwError: Error? = nil

        let exception = tryBlock {
            guard let handle = FileHandle(forWritingAtPath: self.name) else {
                throwError = FileError.fileNotWriteable(file: self.name)
                return
            }

            guard let data = string.data(using: String.Encoding.utf8) else {
                throwError = FileError.fileNotWriteable(file: self.name)
                return
            }

            handle.seekToEndOfFile()
            handle.write(data)
            handle.closeFile()
        }

        if let err = throwError {
            throw err
        }

        guard exception == nil else {
            throw FileError.fileNotWriteable(file: name)
        }
    }

    open func append(_ srcFile: File) throws {
        let outputStream = try getOutputStream(true)
        outputStream.open()
        defer {
            outputStream.close()
        }

        let inputStream = try srcFile.getInputStream()
        inputStream.open()
        defer {
            inputStream.close()
        }

        let bufSize = 1024 * 1024
        var buf = [UInt8](repeating: 0, count: bufSize)

        var bytesRead = 0
        repeat {
            bytesRead = inputStream.read(&buf, maxLength: bufSize)
            if bytesRead > 0 {
                if outputStream.write(buf, maxLength: bytesRead) == -1 {
                    throw FileError.fileNotWriteable(file: name)
                }
            }
        } while bytesRead > 0
    }

    // MARK: Read operations

    open func getContents() throws -> String {
        guard let data = File.manager.contents(atPath: name) else {
            throw FileError.fileNotReadable(file: name)
        }

        guard let str = NSString(data: data, encoding:String.Encoding.utf8.rawValue) else {
            throw FileError.fileNotReadable(file: name)
        }
        
        return str as String
    }

}
