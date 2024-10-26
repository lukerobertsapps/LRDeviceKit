//
//  MessageHandlerTests.swift
//  
//
//  Created by Luke Roberts on 02/02/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class MessageHandlerTests: XCTestCase {

    func testMessageHandlerRequestCharacteristicIsCorrect() {
        let mock = MockTransport()
        let sut = MessageHandler(transport: mock, timeout: 0.1)
        XCTAssertEqual(sut.requestCharacteristic, CBUUID.requestUUID)
    }

    func testMessageHandlerReplyCharacteristicIsCorrect() {
        let mock = MockTransport()
        let sut = MessageHandler(transport: mock, timeout: 0.1)
        XCTAssertEqual(sut.replyCharacteristic, CBUUID.replyUUID)
    }

    func testValueUpdateTaskGetsCreatedOnInit() {
        let mock = MockTransport()
        let sut = MessageHandler(transport: mock, timeout: 0.1)
        XCTAssertNotNil(sut.valueUpdateTask)
    }

    func testSendingNonMessageThrowsError() async throws {
        let transportableType = OtherTransportableType(from: Data())!
        let mock = MockTransport()
        let sut = MessageHandler(transport: mock, timeout: 0.1)
        do {
            _ = try await sut.send(transportableType)
            XCTFail("Should not have succeeded")
        } catch {
            XCTAssertEqual(error as? MessageHandlerError, MessageHandlerError.invalidTransportableData)
        }
    }

    func testSendingValidMessageGetsSentToTransport() async throws {
        let message = Message(command: .getName)
        let mock = MockTransport()
        let sut = MessageHandler(transport: mock, timeout: 0.1)
        _ = try? await sut.send(message)
        let packed = message.pack()
        XCTAssertEqual(packed, mock.sentData?.0)
    }

    func testTheRequestUUIDGetsUsedForSending() async throws {
        let message = Message(command: .getName)
        let mock = MockTransport()
        let sut = MessageHandler(transport: mock, timeout: 0.1)
        _ = try? await sut.send(message)
        let expectedUUID = CBUUID.requestUUID.uuidString
        XCTAssertEqual(expectedUUID, mock.sentData?.1)
    }
}

private class OtherTransportableType: Transportable {
    var payload: Data?
    required init?(from data: Data) { }
    func pack() -> Data { return Data() }
}
