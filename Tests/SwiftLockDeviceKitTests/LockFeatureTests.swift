//
//  LockFeatureTests.swift
//  
//
//  Created by Luke Roberts on 10/02/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class LockFeatureTests: XCTestCase {

    func testGetStateCorrectlyWorksForUnlocked() async throws {
        let mock = MockHandler()
        mock.dataToReturn = Message(type: .reply, command: .getLockState, payload: Data([0x01]))
        let sut = LockFeature(handler: mock)
        let result = try await sut.getLockState()
        XCTAssertEqual(result, .unlocked)
    }

    func testGetStateCorrectlyWorksForLocked() async throws {
        let mock = MockHandler()
        mock.dataToReturn = Message(type: .reply, command: .getLockState, payload: Data([0x00]))
        let sut = LockFeature(handler: mock)
        let result = try await sut.getLockState()
        XCTAssertEqual(result, .locked)
    }

    func testGetLockStateThrowsIfHandlerError() async throws {
        let mock = MockHandler()
        mock.errorToThrow = .invalidMessageType
        let sut = LockFeature(handler: mock)
        do {
            _ = try await sut.getLockState()
            XCTFail("Should not have passed")
        } catch {
            XCTAssertEqual(error as? MessageHandlerError, .invalidMessageType)
        }
    }

    func testGetLockStateDefaultsToLockedIfPayloadMalformed() async throws {
        let mock = MockHandler()
        mock.dataToReturn = Message(type: .reply, command: .getLockState, payload: Data([0xFF, 0x52]))
        let sut = LockFeature(handler: mock)
        let result = try await sut.getLockState()
        XCTAssertEqual(result, .locked)
    }
}
