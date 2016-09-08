//
//  FileTest-SHA256TreeHash.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import XCTest
@testable import SwiftHelperKit

class FileTestSHA256TreeHash: BaseTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetChunkSHA256Hashes() {
        let part1 = String(repeating: String(("a" as Character)), count: 1024 * 1024)
        let part2 = String(repeating: String(("b" as Character)), count: 100)
        let file = try! File.createTemp()
        try! file.setContents(part1 + part2)
        XCTAssertEqual(Int64((1024 * 1024) + 100), file.size)

        let exp = [
            "9bc1b2a288b26af7257a36277ae3816a7d4f16e89c1e7e77d0a5c48bad62b360".dataFromHexString()!,
            "d6cbb053abf2933889a0ccbf6ac244623a63a2e3397e991dde09266bdaa932d1".dataFromHexString()!,
        ]

        let file1 = try! File.createTemp()
        try! file1.setContents(part1)
        let hash1 = try! file1.computeSHA256()
        XCTAssertEqual(exp[0], hash1.dataFromHexString()!)
        try! file1.delete()

        let file2 = try! File.createTemp()
        try! file2.setContents(part2)
        let hash2 = try! file2.computeSHA256()
        XCTAssertEqual(exp[1], hash2.dataFromHexString()!)
        try! file2.delete()

        let hashes = try! file.getChunkSHA256Hashes(1024 * 1024)
        XCTAssertEqual(exp, hashes)
        try! file.delete()
    }

    func testComputeSHA256TreeHash() {
        let exp = "058f03749e2e4d67dfc1c2439a85daabe1f8f7c580b2e7264f0fa8f0addfd371"

        var hashes = [
            "618278d32b4959a7de232546fe6e1ce9c398aa253fb604056fbf670ab116ede2".dataFromHexString()!,
            "8db8e6b9b395dd49902fff3085503aad6e0d8c6b68e7a6ea1bca15773be9aa60".dataFromHexString()!,
            "27680541a8b4a1ae8a7946918498f0720ce6a691143e9ff90607e3b50e74ce3b".dataFromHexString()!,
            "6d00b8609f60742aebcda7080bb036527d88b2384690dba82922f119d3a7e74f".dataFromHexString()!,
        ]
        XCTAssertEqual(exp, TreeHash.computeSHA256TreeHash(hashes))

        hashes = [
            "76b99c0f5b1e822a33956e48f357144ffd2b5578f1eaeb9bad73cb7d36a744b3".dataFromHexString()!,
            "681ec4df431da6ce2e83cb21713e5fad4b7ee048a1cf576e589f20ed5526d0c0".dataFromHexString()!,
        ]
        XCTAssertEqual(exp, TreeHash.computeSHA256TreeHash(hashes))
    }

}
