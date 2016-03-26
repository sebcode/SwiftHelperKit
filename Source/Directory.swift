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
public class Directory: FilePath {

    // MARK: Factories

    /// Returns the application support directory relative to the user's home directory
    /// (`~/Library/Application Support`).
    ///
    /// - returns: `Directory` instance.
    public class func applicationSupportDirectory() -> Directory {
        let urls = Directory.manager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let dirUrl = urls[urls.count - 1] as NSURL
        return Directory(name: dirUrl.path!)
    }

    /// Returns the user's `Downloads` directory.
    ///
    /// - returns: `Directory` instance.
    public class func downloadsDirectory() -> Directory {
        let urls = Directory.manager.URLsForDirectory(.DownloadsDirectory, inDomains: .UserDomainMask)
        let dirUrl = urls[urls.count - 1] as NSURL
        return Directory(name: dirUrl.path!)
    }

    /// Returns the user's home directory (e.g. `/Users/peter`).
    ///
    /// - returns: `Directory` instance.
    public class func homeDirectory() -> Directory {
        return Directory(name: NSHomeDirectory())
    }

    /// Returns the user's directory for temporary files.
    ///
    /// - returns: `Directory` instance.
    public class func tempDirectory() -> Directory {
        return Directory(name: NSTemporaryDirectory())
    }

    /// Returns a subdirectory relative to this directory.
    ///
    /// - parameter name: Name of the subdirectory.
    /// - returns: `Directory` instance.
    public func subDirectory(name: String) -> Directory {
        let subUrl = url?.URLByAppendingPathComponent(name)
        return Directory(name: subUrl!.path!)
    }

    // MARK: Static Helper

    /// Finds the common directory for the list of directories provided.
    ///
    /// Example: The common directory for `/tmp/test1` and `/tmp/test2`
    /// is `/tmp`.
    ///
    /// - parameter directories: Array of `Directory` instances.
    /// - returns: `Directory` instance of `nil` on failure.
    public class func findCommonDirectory(directories: [Directory]) -> Directory? {
        if directories.count == 0 {
            return nil
        }

        if directories.count == 1 {
            return directories[0]
        }

        var dirParts = [[String]]()
        var commonParts = [String]()

        for dir in directories {
            let parts = dir.name.characters.split { $0 == "/" }.map { String($0) }
            dirParts += [ parts ]
        }

        dirParts.sortInPlace { $0.count < $1.count }

        guard let shortestDirParts = dirParts.first else { return nil }

        outer: for (index, part) in shortestDirParts.enumerate() {
            for parts in dirParts {
                if part != parts[index] {
                    break outer
                }
            }

            commonParts += [ part ]
        }

        return Directory(name: "/" + commonParts.joinWithSeparator("/"))
    }

    // MARK: File factories

    /// Returns a new instance of `File` for the given relative file name
    /// for this directory.
    ///
    /// - parameter name: Relative file name.
    /// - returns: A new `File` instance.
    public func file(name: String) -> File {
        let subUrl = url?.URLByAppendingPathComponent(name)
        return File(name: subUrl!.path!)
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
    public func nextNewFile(name: String, appendix: String = "", tries: Int = 10000) -> File? {
        let baseName = file(name).name
        let append = (appendix == "" ? "" : ".\(appendix)")

        var targetFile = file(name + append)

        var counter = 1

        while targetFile.exists {
            counter += 1
            let n = NSString(string: baseName).stringByDeletingPathExtension + " (\(counter))"
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
    public func glob(pattern: String) throws -> [FilePath]? {
        var globt = glob_t()
        let p = NSString(string: name).stringByAppendingPathComponent(pattern)
        let ret = Darwin.glob(p, GLOB_TILDE | GLOB_BRACE | GLOB_MARK, nil, &globt)
        defer { globfree(&globt) }

        if ret == GLOB_NOMATCH {
            return []
        }

        guard ret == 0 else {
            throw FileError.FileNotReadable(file: name)
        }

        var result = [FilePath]()

        for i in 0 ..< Int(globt.gl_matchc) {
            guard let path = String.fromCString(globt.gl_pathv[i]) else {
                continue
            }

            var isDir: ObjCBool = false
            if FilePath.manager.fileExistsAtPath(path, isDirectory: &isDir) {
                result += [ isDir ? Directory(name: path) : File(name: path) ]
            }
        }

        return result
    }

    /// Finds all files and directories recursivly relative to this
    /// directory.
    ///
    /// - returns: Array of `File` and `Directory` instances.
    public func files() -> [FilePath] {
        let fileManager = NSFileManager.defaultManager()
        guard let enumerator = fileManager.enumeratorAtPath(name) else {
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

    /// Returns the parent directory for this directory.
    ///
    /// - returns: `Directory` instance.
    public var parentDirectory: Directory {
        guard let parentUrl = url?.URLByDeletingLastPathComponent else { return Directory(name: "/") }
        return Directory(name: parentUrl.path!)
    }

    /// Checks if this is a existing directory.
    ///
    /// - returns: `true` if directory exists.
    public override var exists: Bool {
        return isDirectory
    }

    // MARK: Write operations

    /// Attemts to create this directory (with intermediate directories).
    /// Throws `FileError.FileNotWritable` on failure.
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

    /// Creates a new empty temporary file relative to this directory.
    ///
    /// - parameter prefix: Prefix for the temporary filename.
    /// - returns: New `File` instance for the temporary file.
    public func createTempFile(prefix: String = "tmp") throws -> File {
        let newFile = file("\(prefix)-\(NSUUID().UUIDString)")
        try newFile.create()
        return newFile
    }
    
}
