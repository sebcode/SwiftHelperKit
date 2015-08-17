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

public class FilePath {

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

    public var url: NSURL? {
        return NSURL(fileURLWithPath: name)
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

}

// MARK: Directory class

public class Directory: FilePath {

    public class func applicationSupportDirectory() -> Directory {
        let urls = Directory.manager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let dirUrl = urls[urls.count - 1] as NSURL
        return Directory(name: dirUrl.path!)
    }

    public class func homeDirectory() -> Directory {
        return Directory(name: NSHomeDirectory())
    }

    // MARK: Convenience properties

    public func file(name: String) -> File {
        let subUrl = url?.URLByAppendingPathComponent(name)
        return File(name: subUrl!.path!)
    }

    public func subDirectory(name: String) -> Directory {
        let subUrl = url?.URLByAppendingPathComponent(name)
        return Directory(name: subUrl!.path!)
    }

    public override var exists: Bool {
        guard let dirUrl = url else {
            return false
        }

        var isDir = false

        do {
            let properties = try dirUrl.resourceValuesForKeys([NSURLIsDirectoryKey])
            if let isDirectory = properties[NSURLIsDirectoryKey] as? NSNumber {
                isDir = isDirectory.boolValue
            }
        } catch _ {
            isDir = false
        }

        return isDir
    }

    // MARK: Write operations

    public override func create() throws {
        guard let dirUrl = url else {
            throw FileError.FileNotWriteable(file: name)
        }

        do {
            try Directory.manager.createDirectoryAtURL(dirUrl, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            throw FileError.FileNotWriteable(file: name)
        }
    }

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
