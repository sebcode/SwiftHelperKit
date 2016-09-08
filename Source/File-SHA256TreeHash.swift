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

    public func getChunkSHA256Hashes(_ chunkSize: Int, progress: ((_ percentDone: Int) -> Bool)? = nil) throws -> [Data] {
        let fileSize = size
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        guard fileSize > 0 else {
            CC_SHA256(nil, 0, &hash);
            let hashData = Data(bytes: hash, count: Int(CC_SHA256_DIGEST_LENGTH))
            return [ hashData ]
        }

        let inputStream = try getInputStream()
        var result = [Data]()

        var buf = [UInt8](repeating: 0, count: chunkSize)
        inputStream.open()

        var bytesRead = 0
        var totalBytesRead = 0
        repeat {
            if progress != nil {
                let percentDone: Float = (Float(totalBytesRead) / Float(fileSize)) * 100.0
                if progress!(Int(percentDone)) == false { return [] }
            }

            bytesRead = inputStream.read(&buf, maxLength: chunkSize)
            if bytesRead < 0 {
                throw FileError.fileNotReadable(file: name)
            }

            totalBytesRead += bytesRead
            if bytesRead > 0 {
                CC_SHA256(&buf, CC_LONG(bytesRead), &hash)
                let hashData = Data(bytes: hash, count: Int(CC_SHA256_DIGEST_LENGTH))
                result.append(hashData)
            }
        } while bytesRead > 0
        
        return result
    }

}

open class TreeHash {

    open class func computeSHA256TreeHash(_ hashes: [Data]) -> String {
        var prevLvlHashes = hashes

        while prevLvlHashes.count > 1 {
            var len = prevLvlHashes.count / 2
            if prevLvlHashes.count % 2 != 0 {
                len += 1
            }

            var currLvlHashes = [Data]()

            var j = 0
            for i in stride(from: 0, to: prevLvlHashes.count, by: 2) {
                if prevLvlHashes.count - i > 1 {
                    let firstPart = prevLvlHashes[i]
                    let secondPart = prevLvlHashes[i + 1]
                    let concatenation = NSMutableData()
                    concatenation.append(firstPart)
                    concatenation.append(secondPart)
                    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
                    CC_SHA256(concatenation.bytes, CC_LONG(concatenation.length), &hash)
                    let hashData = Data(bytes: hash, count: Int(CC_SHA256_DIGEST_LENGTH))
                    currLvlHashes.insert(hashData, at: j)
                } else {
                    currLvlHashes.insert(prevLvlHashes[i], at: j)
                }
                j += 1
            }

            prevLvlHashes = currLvlHashes
        }

        return prevLvlHashes[0].hexString()
    }
    
}
