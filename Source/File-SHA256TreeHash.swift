//
//  File-SHA256TreeHash.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

// http://spin.atomicobject.com/2015/02/23/c-libraries-swift/
import CommonCrypto

extension File {

    public func getChunkSHA256Hashes(chunkSize: Int, progress: ((percentDone: Int) -> Bool)? = nil) throws -> [NSData] {
        let fileSize = size
        var hash: [UInt8] = Array(count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)

        guard fileSize > 0 else {
            CC_SHA256(nil, 0, &hash);
            let hashData = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
            return [ hashData ]
        }

        let inputStream = try getInputStream()
        var result = [NSData]()

        var buf = [UInt8](count: chunkSize, repeatedValue: 0)
        inputStream.open()

        var bytesRead = 0
        var totalBytesRead = 0
        repeat {
            if progress != nil {
                let percentDone: Float = (Float(totalBytesRead) / Float(fileSize)) * 100.0
                if progress!(percentDone: Int(percentDone)) == false { return [] }
            }

            bytesRead = inputStream.read(&buf, maxLength: chunkSize)
            if bytesRead < 0 {
                throw FileError.FileNotReadable(file: name)
            }

            totalBytesRead += bytesRead
            if bytesRead > 0 {
                CC_SHA256(&buf, CC_LONG(bytesRead), &hash)
                let hashData = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
                result.append(hashData)
            }
        } while bytesRead > 0
        
        return result
    }

}

public class TreeHash {

    public class func computeSHA256TreeHash(hashes: [NSData]) -> String {
        var prevLvlHashes = hashes

        while prevLvlHashes.count > 1 {
            var len = prevLvlHashes.count / 2
            if prevLvlHashes.count % 2 != 0 {
                len += 1
            }

            var currLvlHashes = [NSData]()

            var j = 0
            for i in 0.stride(to: prevLvlHashes.count, by: 2) {
                if prevLvlHashes.count - i > 1 {
                    let firstPart = prevLvlHashes[i]
                    let secondPart = prevLvlHashes[i + 1]
                    let concatenation = NSMutableData()
                    concatenation.appendData(firstPart)
                    concatenation.appendData(secondPart)
                    var hash: [UInt8] = Array(count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
                    CC_SHA256(concatenation.bytes, CC_LONG(concatenation.length), &hash)
                    let hashData = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
                    currLvlHashes.insert(hashData, atIndex: j)
                } else {
                    currLvlHashes.insert(prevLvlHashes[i], atIndex: j)
                }
                j += 1
            }

            prevLvlHashes = currLvlHashes
        }

        return prevLvlHashes[0].hexString()
    }
    
}
