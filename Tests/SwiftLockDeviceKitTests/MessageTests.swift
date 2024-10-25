//
//  MessageTests.swift
//  
//
//  Created by Luke Roberts on 27/01/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class MessageTests: XCTestCase {

    func testMessageTypeIsRequestByDefault() {
        let sut = Message(command: .startNetworkListen)
        XCTAssertEqual(sut.type, .request)
    }

    func testMessageIsNotEncryptedByDefault() {
        let sut = Message(command: .startNetworkListen)
        XCTAssertFalse(sut.isEncrypted)
    }

    func testRequestTypeIsPackedCorrectly() {
        let sut = Message(type: .request, command: .startNetworkListen)
        let packed = sut.pack()
        XCTAssertEqual(packed[1], 0x01)
    }

    func testReplyTypeIsPackedCorrectly() {
        let sut = Message(type: .reply, command: .startNetworkListen)
        let packed = sut.pack()
        XCTAssertEqual(packed[1], 0x02)
    }

    func testEncryptedPackedCorrectly() {
        let sut = Message(command: .startNetworkListen, isEncrypted: true)
        let packed = sut.pack()
        XCTAssertEqual(packed[4], 0x01)
    }

    func testNotEncryptedIsPackedCorrectly() {
        let sut = Message(command: .startNetworkListen, isEncrypted: false)
        let packed = sut.pack()
        XCTAssertEqual(packed[4], 0x00)
    }

    func testLengthPackedCorrectlyWithNoPayload() {
        let sut = Message(command: .startNetworkListen, payload: nil)
        let packed = sut.pack()
        print(packed.count)
        XCTAssertEqual(packed[0], 0x05)
    }

    func testLengthPackedCorrectlyWith4BytePayload() {
        let payload = Data([0x00, 0x00, 0x00, 0x00])
        let sut = Message(command: .startNetworkListen, payload: payload)
        let packed = sut.pack()
        XCTAssertEqual(packed[0], 0x09)
    }

    func testMalformedDataReturnsNil() {
        let data = Data([0xFF, 0xFF])
        let sut = Message(from: data)
        XCTAssertNil(sut)
    }

    func testMessageUnpackedWithValidData() {
        let data = Data([0x05, 0x01, 0x01, 0x02, 0x01])
        let sut = Message(from: data)
        XCTAssertNotNil(sut)
    }

    func testMessageUnpackedWithPayload() {
        let data = Data([
            0x07, 0x01, 0x01, 0x02, 0x01, 0xFF, 0x00
        ])
        let sut = Message(from: data)
        XCTAssertEqual(sut?.payload, Data([0xFF, 0x00]))
    }
}
