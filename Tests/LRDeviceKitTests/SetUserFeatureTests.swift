//
//  SetUserFeatureTests.swift
//  
//
//  Created by Luke Roberts on 23/02/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class SetUserFeatureTests: XCTestCase {

    func testUIDIsEncodedIntoUTF8() async throws {
        let mock = MockHandler()
        let sut = SetUserFeature(handler: mock)
        try await sut.register(user: "test")
        let result = mock.dataSent as? Message
        XCTAssertEqual(result?.payload, Data([0x74, 0x65, 0x73, 0x74]))
    }

    func testFeatureThrowsErrorIfHandlerFails() async throws {
        let mock = MockHandler()
        let sut = SetUserFeature(handler: mock)
        mock.errorToThrow = .invalidMessageType
        do {
            try await sut.register(user: UUID().uuidString)
            XCTFail("Should not have passed")
        } catch {
            XCTAssertEqual(error as? MessageHandlerError, .invalidMessageType)
        }
    }
}
