//
//  Directory.swift
//  SwiftHelperKit
//
//  Created by Sebastian Volland on 20/08/15.
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

/**
    `Directory` is a wrapper class for a file system directory.
*/
open class Directory: FilePath {

    // MARK: Factories

    /// Returns the application support directory relative to the user's home directory
    /// (`~/Library/Application Support`).
    ///
    /// - returns: `Directory` instance.
    open class func applicationSupportDirectory() -> Directory {
        let urls = Directory.manager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let dirUrl = urls[urls.count - 1] as URL
        return Directory(name: dirUrl.path)
    }

    /// Returns the user's `Downloads` directory.
    ///
    /// - returns: `Directory` instance.
    open class func downloadsDirectory() -> Directory {
        let urls = Directory.manager.urls(for: .downloadsDirectory, in: .userDomainMask)
        let dirUrl = urls[urls.count - 1] as URL
        return Directory(name: dirUrl.path)
    }

    /// Returns the user's home directory (e.g. `/Users/peter`).
    ///
    /// - returns: `Directory` instance.
    open class func homeDirectory() -> Directory {
        return Directory(name: NSHomeDirectory())
    }

    /// Returns the user's directory for temporary files.
    ///
    /// - returns: `Directory` instance.
    open class func tempDirectory() -> Directory {
        return Directory(name: NSTemporaryDirectory())
    }

    /// Returns a subdirectory relative to this directory.
    ///
    /// - parameter name: Name of the subdirectory.
    /// - returns: `Directory` instance.
    open func subDirectory(_ name: String) -> Directory {
        let subUrl = url?.appendingPathComponent(name)
        return Directory(name: subUrl!.path)
    }

    // MARK: Static Helper

    /// Finds the common directory for the list of directories provided.
    ///
    /// Example: The common directory for `/tmp/test1` and `/tmp/test2`
    /// is `/tmp`.
    ///
    /// - parameter directories: Array of `Directory` instances.
    /// - returns: `Directory` instance of `nil` on failure.
    open class func findCommonDirectory(_ directories: [Directory]) -> Directory? {
        if directories.count == 0 {
            return nil
        }

        if directories.count == 1 {
            return directories[0]
        }

        var dirParts = [[String]]()
        var commonParts = [String]()

        for dir in directories {
            let parts = dir.name.split { $0 == "/" }.map { String($0) }
            dirParts += [ parts ]
        }

        dirParts.sort { $0.count < $1.count }

        guard let shortestDirParts = dirParts.first else { return nil }

        outer: for (index, part) in shortestDirParts.enumerated() {
            for parts in dirParts {
                if part != parts[index] {
                    break outer
                }
            }

            commonParts += [ part ]
        }

        return Directory(name: "/" + commonParts.joined(separator: "/"))
    }

    // MARK: File factories

    /// Returns a new instance of `File` for the given relative file name
    /// for this directory.
    ///
    /// - parameter name: Relative file name.
    /// - returns: A new `File` instance.
    open func file(_ name: String) -> File {
        let subUrl = url?.appendingPathComponent(name)
        return File(name: subUrl!.path)
    }

    /// Find a new non-existing filename similar to `name`.
    /// Filenames are counted up like `Testfile.txt`, `Testfile (2).txt`, `Testfile (3).txt`.
    ///
    /// If `appendix` is specified, it will be appended as an additional file extension,
    /// e.g. appendix `part` would return `Testfile.txt.part`, `Testfile (2).txt.part`,
    /// `Testfile (2).txt.part`, etc.
    ///
    /// - parameter name: Base filename without path.
    /// - parameter appendix: Optional additional file extension.
    /// - parameter tries: Maximum tries to find a non-existant filename.
    /// - returns: A new `File` object or nil on failure.
    open func nextNewFile(_ name: String, appendix: String = "", tries: Int = 10000) -> File? {
        let baseName = file(name).name
        let append = (appendix == "" ? "" : ".\(appendix)")

        var targetFile = file(name + append)

        var counter = 1

        while targetFile.exists {
            counter += 1
            let n = NSString(string: baseName).deletingPathExtension + " (\(counter))"
            let ext = NSString(string: baseName).pathExtension
            let newName = n + (ext == "" ? "" : ".") + ext + append
            targetFile = File(name: newName)

            if counter >= tries {
                return nil
            }
        }

        return targetFile
    }

    /// Wrapper for the C-function glob(3). Finds files and directories based
    /// on a pattern relative to this directory. Accepts patterns like `*.png`.
    ///
    /// - parameter pattern: Glob-pattern.
    /// - returns: Array of `File` and `Directory` instances or `nil` on failure.
    open func glob(_ pattern: String) throws -> [FilePath]? {
        var globt = glob_t()
        let p = NSString(string: name).appendingPathComponent(pattern)
        let ret = Darwin.glob(p, GLOB_TILDE | GLOB_BRACE | GLOB_MARK, nil, &globt)
        defer { globfree(&globt) }

        if ret == GLOB_NOMATCH {
            return []
        }

        guard ret == 0 else {
            throw FileError.fileNotReadable(file: name)
        }

        var result = [FilePath]()

        for i in 0 ..< Int(globt.gl_matchc) {
            guard let path = String(validatingUTF8: globt.gl_pathv[i]!) else {
                continue
            }

            var isDir: ObjCBool = false
            if FilePath.manager.fileExists(atPath: path, isDirectory: &isDir) {
                result += [ isDir.boolValue ? Directory(name: path) : File(name: path) ]
            }
        }

        return result
    }

    /// Finds all files and directories recursivly relative to this
    /// directory.
    ///
    /// - returns: Array of `File` and `Directory` instances.
    open func files() -> [FilePath] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: name) else {
            return []
        }

        var result = [FilePath]()

        while let name = enumerator.nextObject() as? String {
            let f = file(name)

            if f.isDirectory {
                result += [ subDirectory(name) ]
            } else {
                result += [ f ]
            }
        }

        return result
    }

    // MARK: Convenience properties

    open var freeDiskSpace: Int64? {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: name)
            let freeSize = attributes[.systemFreeSize] as? NSNumber
            if (freeSize != nil) {
                return freeSize?.int64Value
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    /// Returns the parent directory for this directory.
    ///
    /// - returns: `Directory` instance.
    open var parentDirectory: Directory {
        guard let parentUrl = url?.deletingLastPathComponent else { return Directory(name: "/") }
        return Directory(name: parentUrl().path)
    }

    /// Checks if this is a existing directory.
    ///
    /// - returns: `true` if directory exists.
    open override var exists: Bool {
        return isDirectory
    }

    // MARK: Write operations

    /// Attemts to create this directory (with intermediate directories).
    /// Throws `FileError.FileNotWritable` on failure.
    open override func create() throws {
        guard let dirUrl = url else {
            throw FileError.fileNotWriteable(file: name)
        }

        do {
            try Directory.manager.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            throw FileError.fileNotWriteable(file: name)
        }
    }

    /// Creates a new empty temporary file relative to this directory.
    ///
    /// - parameter prefix: Prefix for the temporary filename.
    /// - returns: New `File` instance for the temporary file.
    open func createTempFile(_ prefix: String = "tmp") throws -> File {
        let newFile = file("\(prefix)-\(UUID().uuidString)")
        try newFile.create()
        return newFile
    }
    
}
