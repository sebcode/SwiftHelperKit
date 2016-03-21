//
//  Directory.swift
//  SwiftHelperKit
//
//  Created by Sebastian Volland on 20/08/15.
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

// MARK: Directory class

public class Directory: FilePath {

    // MARK: Factories

    public class func applicationSupportDirectory() -> Directory {
        let urls = Directory.manager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let dirUrl = urls[urls.count - 1] as NSURL
        return Directory(name: dirUrl.path!)
    }

    public class func downloadsDirectory() -> Directory {
        let urls = Directory.manager.URLsForDirectory(.DownloadsDirectory, inDomains: .UserDomainMask)
        let dirUrl = urls[urls.count - 1] as NSURL
        return Directory(name: dirUrl.path!)
    }

    public class func homeDirectory() -> Directory {
        return Directory(name: NSHomeDirectory())
    }

    public class func tempDirectory() -> Directory {
        return Directory(name: NSTemporaryDirectory())
    }

    public func subDirectory(name: String) -> Directory {
        let subUrl = url?.URLByAppendingPathComponent(name)
        return Directory(name: subUrl!.path!)
    }

    // MARK: Static Helper

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

    public override var exists: Bool {
        return isDirectory
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

    /// Create a new empty temporary file
    public func createTempFile(prefix: String = "tmp") throws -> File {
        let newFile = file("\(prefix)-\(NSUUID().UUIDString)")
        try newFile.create()
        return newFile
    }
    
}
