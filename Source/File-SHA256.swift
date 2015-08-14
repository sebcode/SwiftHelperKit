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

    func computeSHA256(range: (from: Int64, to: Int64)) throws -> String {
        var hash: [UInt8] = Array(count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)

        let expectedTotalBytes: Int64 = range.to - range.from + 1

        guard exists else {
            throw FileError.FileNotReadable(file: name)
        }

        guard size > 0 else {
            if expectedTotalBytes > 0 {
                throw FileError.FileNotReadable(file: name)
            }

            CC_SHA256(nil, 0, &hash);
            return hash.map { byte in byte.toHex() }.reduce("", combine: +)
        }

        guard let fileHandle = NSFileHandle(forReadingAtPath: name) else {
            throw FileError.FileNotReadable(file: name)
        }

        fileHandle.seekToFileOffset(UInt64(range.from))

        let bufSize: Int64 = 1024 * 1024
        var buf: NSData
        var bytesLeft: Int64 = range.to - range.from + 1
        var bytesReadTotal: Int64 = 0

        var context = CC_SHA256_CTX()
        CC_SHA256_Init(&context)

        repeat {
            var readBytes: Int64 = bufSize
            if readBytes > bytesLeft {
                readBytes = bytesLeft
            }
            buf = fileHandle.readDataOfLength(Int(readBytes))
            if buf.length > 0 {
                CC_SHA256_Update(&context, buf.bytes, CC_LONG(buf.length))
                bytesLeft -= Int64(buf.length)
                bytesReadTotal += Int64(buf.length)
            }
        } while buf.length != 0

        if bytesReadTotal != expectedTotalBytes {
            throw FileError.FileNotReadable(file: name)
        }

        CC_SHA256_Final(&hash, &context)
        return hash.map { byte in byte.toHex() }.reduce("", combine: +)
    }

    func computeSHA256Async(range: (from: Int64, to: Int64), done: (result: String?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var hashStr: String? = nil
            do {
                hashStr = try self.computeSHA256(range)
            } catch { }

            dispatch_async(dispatch_get_main_queue()) {
                done(result: hashStr)
            }
        }
    }

    func computeSHA256() throws -> String {
        var hash: [UInt8] = Array(count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)

        guard exists else {
            throw FileError.FileNotReadable(file: name)
        }

        guard size > 0 else {
            CC_SHA256(nil, 0, &hash);
            return hash.map { byte in byte.toHex() }.reduce("", combine: +)
        }

        let bufSize = 1024 * 1024
        var buf = [UInt8](count: bufSize, repeatedValue: 0)

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
        return hash.map { byte in byte.toHex() }.reduce("", combine: +)
    }

    func computeSHA256Async(done: (result: String?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var hashStr: String? = nil
            do {
                hashStr = try self.computeSHA256()
            } catch { }

            dispatch_async(dispatch_get_main_queue()) {
                done(result: hashStr)
            }
        }
    }

}
