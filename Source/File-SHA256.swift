//
//  File-SHA256.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

// File Extension for SHA256 hash calculation.

import Foundation

// http://spin.atomicobject.com/2015/02/23/c-libraries-swift/
import CommonCrypto

extension File {

    public func computeSHA256(_ range: (from: Int64, to: Int64)) throws -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        let expectedTotalBytes: Int64 = range.to - range.from + 1

        guard exists else {
            throw FileError.fileNotReadable(file: name)
        }

        guard size > 0 else {
            if expectedTotalBytes > 0 {
                throw FileError.fileNotReadable(file: name)
            }

            CC_SHA256(nil, 0, &hash);
            return hash.map { byte in byte.toHex() }.reduce("", +)
        }

        var resultHash = ""
        var throwError: Error? = nil

        let exception = tryBlock {
            guard let fileHandle = FileHandle(forReadingAtPath: self.name) else {
                throwError = FileError.fileNotReadable(file: self.name)
                return
            }

            fileHandle.seek(toFileOffset: UInt64(range.from))

            let bufSize: Int64 = 1024 * 1024
            var bytesLeft: Int64 = range.to - range.from + 1
            var bytesReadTotal: Int64 = 0

            var context = CC_SHA256_CTX()
            CC_SHA256_Init(&context)

            repeat {
                var readBytes: Int64 = bufSize
                if bytesLeft < readBytes {
                    readBytes = bytesLeft
                }
                var didRead = 0
                autoreleasepool {
                    let buf = fileHandle.readData(ofLength: Int(readBytes))
                    didRead = buf.count
                    if buf.count > 0 {
                        _ = buf.withUnsafeBytes { bytes in
                            CC_SHA256_Update(&context, bytes, CC_LONG(buf.count))
                        }
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

            fileHandle.closeFile()

            CC_SHA256_Final(&hash, &context)
            resultHash = hash.map { byte in byte.toHex() }.reduce("", +)
        }

        if let err = throwError {
            throw err
        }

        guard exception == nil else {
            throw FileError.fileNotReadable(file: name)
        }

        return resultHash
    }

    public func computeSHA256() throws -> String {
        var hash: [UInt8] = Array(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        guard exists else {
            throw FileError.fileNotReadable(file: name)
        }

        guard size > 0 else {
            CC_SHA256(nil, 0, &hash);
            return hash.map { byte in byte.toHex() }.reduce("", +)
        }

        let bufSize = 1024 * 1024
        var buf = [UInt8](repeating: 0, count: bufSize)

        var context = CC_SHA256_CTX()
        CC_SHA256_Init(&context)

        let inputStream = try getInputStream()
        inputStream.open()

        var bytesRead = 0
        repeat {
            bytesRead = inputStream.read(&buf, maxLength: bufSize)
            if bytesRead > 0 {
                CC_SHA256_Update(&context, &buf, CC_LONG(bytesRead))
            }
        } while bytesRead > 0

        CC_SHA256_Final(&hash, &context)
        return hash.map { byte in byte.toHex() }.reduce("", +)
    }

}
