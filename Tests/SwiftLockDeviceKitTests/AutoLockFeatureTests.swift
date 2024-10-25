//
//  AutoLockFeatureTests.swift
//  
//
//  Created by Luke Roberts on 04/02/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class AutoLockFeatureTests: XCTestCase {

    func testAutoLockTimeGetsSentCorrectly() async throws {
        let mock = MockHandler()
        let sut = AutoLockFeature(handler: mock)
        try await sut.setAutoLock(time: 5)
        let result = mock.dataSent as? Message
        XCTAssertEqual(result?.payload, Data([0x05]))
    }

    func testNilMeansNoPayload() async throws {
        let mock = MockHandler()
        let sut = AutoLockFeature(handler: mock)
        try await sut.setAutoLock(time: nil)
        let result = mock.dataSent as? Message
        XCTAssertNil(result?.payload)
    }

    func testMaximumValueCappedAt231() async throws {
        let mock = MockHandler()
        let sut = AutoLockFeature(handler: mock)
        try await sut.setAutoLock(time: 999)
        let result = mock.dataSent as? Message
        XCTAssertEqual(result?.payload, Data([0xE7]))
    }

    func testFeatureThrowsErrorIfHandlerFails() async throws {
        let mock = MockHandler()
        let sut = AutoLockFeature(handler: mock)
        mock.errorToThrow = .invalidMessageType
        do {
            try await sut.setAutoLock(time: 1)
            XCTFail("Should not have passed")
        } catch {
            XCTAssertEqual(error as? MessageHandlerError, .invalidMessageType)
        }
    }

    func testNegativeTimeConvertedIntoPositive() async throws {
        let mock = MockHandler()
        let sut = AutoLockFeature(handler: mock)
        try await sut.setAutoLock(time: -1)
        let result = mock.dataSent as? Message
        XCTAssertEqual(result?.payload, Data([0x01]))
    }
}
