//
//  DataStringRepresentationTests.swift
//  
//
//  Created by Luke Roberts on 26/01/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class DataStringRepresentationTests: XCTestCase {

    func testDataConvertsCorrectly() {
        let data = Data([0x01, 0x02, 0x03])
        XCTAssertEqual(data.stringRepresentation, "010203")
    }

    func testEmptyDataConvertsToEmptyString() {
        let data = Data()
        XCTAssertTrue(data.stringRepresentation.isEmpty)
    }
}
