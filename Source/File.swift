//
//  File.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

// MARK: Error types

public enum FileError: ErrorType {
    case FileNotFound(file: String)
    case FileNotReadable(file: String)
    case FileNotWriteable(file: String)
}

extension FileError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .FileNotFound(let file):
            return "File not found: \(file)"
        case .FileNotReadable(let file):
            return "File not readable: \(file)"
        case .FileNotWriteable(let file):
            return "File not writeable: \(file)"
        }
    }
}

// MARK: Base class

public func ==(lhs: FilePath, rhs: FilePath) -> Bool {
    return lhs.name == rhs.name
}

public class FilePath: CustomStringConvertible, Equatable {

    static let manager = NSFileManager.defaultManager()

    public let name: String
    
    // MARK: Initializers

    public required init(name: String) {
        self.name = NSString(string: name).stringByStandardizingPath
    }

    public class func create(name: String) throws -> Self {
        let file = self.init(name: name)
        try file.create()
        return file
    }

    public class func existing(name: String) throws -> Self {
        let file = self.init(name: name)
        try file.checkExists()
        return file
    }

    // MARK: Convenience properties

    public var description: String {
        return name
    }

    public var url: NSURL? {
        return NSURL(fileURLWithPath: name)
    }

    public var baseName: String {
        return NSString(string: name).lastPathComponent
    }

    public var exists: Bool {
        return FilePath.manager.fileExistsAtPath(name)
    }

    public func checkExists() throws {
        if !exists {
            throw FileError.FileNotFound(file: name)
        }
    }

    public var displayName: String {
        return FilePath.manager.displayNameAtPath(name)
    }

    public var mtime: NSDate? {
        do {
            let attr: NSDictionary = try FilePath.manager.attributesOfItemAtPath(name)
            return attr.fileModificationDate()
        } catch {
            return nil
        }
    }

    // MARK: Convenience functions

    public func nameWithoutExtension(ext: String = "") -> String {
        if ext == "" || NSString(string: name).pathExtension == ext {
            return NSString(string: name).stringByDeletingPathExtension
        }

        return name
    }

    // MARK: Write operations

    public func create() throws {
        // Abstract
    }

    // MARK: Delete operations

    public func delete() throws {
        try FilePath.manager.removeItemAtPath(name)
    }

    public func deleteIfExists() -> Bool {
        do {
            try delete()
            return true
        } catch {
            return false
        }
    }

    #if os(OSX)
    public func trash() -> File? {
        guard let trashUrl = url else {
            return nil
        }

        do {
            var resultUrl: NSURL?
            try File.manager.trashItemAtURL(trashUrl, resultingItemURL: &resultUrl)
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

public class File: FilePath {

    // MARK: Convenience properties

    public var size: Int64 {
        do {
            let attr: NSDictionary = try File.manager.attributesOfItemAtPath(name)
            return Int64(attr.fileSize())
        } catch {
            return 0
        }
    }

    // MARK: Write operations

    public override func create() throws {
        if !File.manager.createFileAtPath(name, contents: nil, attributes: nil) {
            throw FileError.FileNotWriteable(file: name)
        }
    }

    public func move(destFile: File) throws {
        do {
            try File.manager.moveItemAtPath(name, toPath: destFile.name)
        } catch {
            throw FileError.FileNotWriteable(file: destFile.name)
        }
    }

    public func copy(destFile: File) throws {
        do {
            try File.manager.copyItemAtPath(name, toPath: destFile.name)
        } catch {
            throw FileError.FileNotWriteable(file: destFile.name)
        }
    }

    public func copy(destFile: File, range:(from: Int64, to: Int64)) throws {
        let expectedTotalBytes: Int64 = range.to - range.from + 1

        guard exists else {
            throw FileError.FileNotReadable(file: name)
        }

        guard size > 0 else {
            if expectedTotalBytes > 0 {
                throw FileError.FileNotReadable(file: name)
            }

            try destFile.setContents("")
            return
        }

        guard let readHandle = NSFileHandle(forReadingAtPath: name) else {
            throw FileError.FileNotReadable(file: name)
        }

        if !destFile.exists {
            try destFile.setContents("")
        }

        guard let writeHandle = NSFileHandle(forWritingAtPath: destFile.name) else {
            throw FileError.FileNotWriteable(file: destFile.name)
        }

        readHandle.seekToFileOffset(UInt64(range.from))

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
                let buf = readHandle.readDataOfLength(Int(readBytes))
                didRead = buf.length
                if buf.length > 0 {
                    writeHandle.writeData(buf)
                    bytesLeft -= Int64(buf.length)
                    bytesReadTotal += Int64(buf.length)
                }
            }
            if didRead == 0 {
                break
            }
        } while bytesLeft > 0

        if bytesReadTotal != expectedTotalBytes {
            throw FileError.FileNotReadable(file: name)
        }

        readHandle.closeFile()
        writeHandle.closeFile()
    }

    public func truncate(size: Int64) throws {
        guard let handle = NSFileHandle(forWritingAtPath: name) else {
            throw FileError.FileNotFound(file: name)
        }

        handle.truncateFileAtOffset(UInt64(size))
    }

    public func setContents(contents: String) throws {
        guard let data = contents.dataUsingEncoding(NSUTF8StringEncoding) else {
            return
        }

        if File.manager.createFileAtPath(name, contents: data, attributes: nil) == false {
            throw FileError.FileNotWriteable(file: name)
        }
    }

    public func append(string: String) throws {
        guard let handle = NSFileHandle(forWritingAtPath: name) else {
            throw FileError.FileNotWriteable(file: name)
        }

        guard let data = NSString(string: string).dataUsingEncoding(NSUTF8StringEncoding) else {
            throw FileError.FileNotWriteable(file: name)
        }
        handle.seekToEndOfFile()
        handle.writeData(data)
        handle.closeFile()
    }

    public func append(srcFile: File) throws {
        let outputStream = try getOutputStream(true)
        outputStream.open()

        let inputStream = try srcFile.getInputStream()
        inputStream.open()

        let bufSize = 1024 * 1024
        var buf = [UInt8](count: bufSize, repeatedValue: 0)

        var bytesRead = 0
        repeat {
            bytesRead = inputStream.read(&buf, maxLength: bufSize)
            if bytesRead > 0 {
                outputStream.write(buf, maxLength: bytesRead)
            }
        } while bytesRead > 0

        inputStream.close()
        outputStream.close()
    }

    // MARK: Read operations

    public func getContents() throws -> String {
        guard let data = File.manager.contentsAtPath(name) else {
            throw FileError.FileNotReadable(file: name)
        }

        guard let str = NSString(data: data, encoding:NSUTF8StringEncoding) else {
            throw FileError.FileNotReadable(file: name)
        }
        
        return str as String
    }

}
