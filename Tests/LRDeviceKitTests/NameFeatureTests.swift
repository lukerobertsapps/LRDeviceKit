//
//  NameFeatureTests.swift
//  
//
//  Created by Luke Roberts on 03/02/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class NameFeatureTests: XCTestCase {

    func testNameIsEncodedIntoUTF8() async throws {
        let mock = MockHandler()
        let sut = NameFeature(handler: mock)
        try await sut.setName(to: "test")
        let result = mock.dataSent as? Message
        XCTAssertEqual(result?.payload, Data([0x74, 0x65, 0x73, 0x74]))
    }

    func testFeatureThrowsErrorIfHandlerFails() async throws {
        let mock = MockHandler()
        let sut = NameFeature(handler: mock)
        mock.errorToThrow = .invalidMessageType
        do {
            try await sut.setName(to: UUID().uuidString)
            XCTFail("Should not have passed")
        } catch {
            XCTAssertEqual(error as? MessageHandlerError, .invalidMessageType)
        }
    }

    func testNameGetsClippedTo20Characters() async throws {
        let mock = MockHandler()
        let sut = NameFeature(handler: mock)
        try await sut.setName(to: "thisnameisdefinitelylongerthan20characters")
        let result = mock.dataSent as? Message
        XCTAssertEqual(result?.payload?.count, 20)
    }
}
