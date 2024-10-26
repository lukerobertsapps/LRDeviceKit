//
//  BoolDataTests.swift
//  
//
//  Created by Luke Roberts on 27/01/2024.
//

import XCTest
@testable import SwiftLockDeviceKit

final class BoolDataTests: XCTestCase {

    func testTrueReturnsOne() {
        let sut = true
        XCTAssertEqual(sut.data, 0x01)
    }

    func testFalseReturnsZero() {
        let sut = false
        XCTAssertEqual(sut.data, 0x00)
    }
}
