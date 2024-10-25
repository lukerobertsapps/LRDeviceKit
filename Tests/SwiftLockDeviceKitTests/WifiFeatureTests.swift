//
//  WifiFeatureTests.swift
//  
//
//  Created by Luke Roberts on 04/02/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class WifiFeatureTests: XCTestCase {

    func testSSIDAndPasswordSeparated() async throws {
        let mock = MockHandler()
        let sut = WifiFeature(handler: mock)
        try await sut.connect(with: "a", and: "b")
        let result = mock.dataSent as? Message
        // check ascii code for separator (1f) is between a and b
        XCTAssertEqual(result?.payload, Data([0x61, 0x1f, 0x62]))
    }

    func testFeatureThrowsErrorIfHandlerFails() async throws {
        let mock = MockHandler()
        let sut = WifiFeature(handler: mock)
        mock.errorToThrow = .invalidMessageType
        do {
            try await sut.connect(with: UUID().uuidString, and: UUID().uuidString)
            XCTFail("Should not have passed")
        } catch {
            XCTAssertEqual(error as? MessageHandlerError, .invalidMessageType)
        }
    }

    func testGetNetworksNoPayloadReturnsEmptyString() async throws {
        let mock = MockHandler()
        let sut = WifiFeature(handler: mock)
        mock.dataToReturn = Message(type: .reply, command: .startNetworkListen)
        let result = try await sut.getAvailableNetworks()
        XCTAssertEqual(result, [])
    }

    func testGetNetworksSplitsListCorrectly() async throws {
        let mock = MockHandler()
        let sut = WifiFeature(handler: mock)
        mock.dataToReturn = Message(
            type: .reply,
            command: .startNetworkListen,
            payload: Data([0x61, 0x1F, 0x62, 0x1F, 0x63])
        )
        let result = try await sut.getAvailableNetworks()
        XCTAssertEqual(result, ["a", "b", "c"])
    }

    func testGetNetworksFiltersOutEmpty() async throws {
        let mock = MockHandler()
        let sut = WifiFeature(handler: mock)
        let networks = ["A", "B", ""]
        let payload = networks.joined(separator: String(UnicodeScalar(31))).data(using: .utf8)
        mock.dataToReturn = Message(type: .reply, command: .startNetworkListen, payload: payload)
        let result = try await sut.getAvailableNetworks()
        XCTAssertEqual(result, ["A", "B"])
    }
}
