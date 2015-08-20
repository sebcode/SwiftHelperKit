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

    // MARK: Convenience properties

    public func file(name: String) -> File {
        let subUrl = url?.URLByAppendingPathComponent(name)
        return File(name: subUrl!.path!)
    }

    public func nextNewFile(name: String) -> File? {
        var targetFile = file(name)

        var counter = 1

        while targetFile.exists {
            let n = NSString(string: name).stringByDeletingPathExtension + " (\(++counter))"
            let ext = NSString(string: name).pathExtension
            let newName = n + (ext == "" ? "" : ".") + ext
            targetFile = file(newName)

            if counter >= 10000 {
                return nil
            }
        }

        return targetFile
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
