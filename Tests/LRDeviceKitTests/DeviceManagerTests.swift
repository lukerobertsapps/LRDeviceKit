//
//  DeviceManagerTests.swift
//  
//
//  Created by Luke Roberts on 21/01/2024.
//
// swiftlint:disable force_cast

import CoreBluetoothMock
import XCTest
@testable import SwiftLockDeviceKit

final class DeviceManagerTests: XCTestCase {

    var centralManager: CBCentralManager!

    override func setUp() {
        super.setUp()
        CBMCentralManagerMock.setupMock()
        centralManager = CBCentralManagerFactory.instance(forceMock: true)
    }

    func testCentralManagerDelegateSetOnInit() {
        let sut = DeviceManager(centralManager: centralManager)
        XCTAssertEqual(centralManager.delegate as? DeviceManager, sut)
    }

    func testBluetoothIsInitiallyOff() {
        let sut = DeviceManager(centralManager: centralManager)
        XCTAssertFalse(sut.bluetoothAvailable)
    }

    func testBluetoothBecomesAvailableWhenCentralManagerPoweredOn() {
        let sut = DeviceManager(centralManager: centralManager)
        let expectation = XCTestExpectation(description: "Bluetooth available")
        CBMCentralManagerMock.simulatePowerOn()
        withObservationTracking {
            _ = sut.bluetoothAvailable
        } onChange: {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(sut.bluetoothAvailable)
    }

    func testStartDiscoveryThrowsErrorIfBluetoothUnavailable() throws {
        let sut = DeviceManager(centralManager: centralManager)
        sut.bluetoothAvailable = false
        XCTAssertThrowsError(try sut.startDiscovery()) { error in
            XCTAssertEqual(error as! DeviceManagerError, .bluetoothUnavailable)
        }
    }

    func testStartDiscoveryCreatesDiscoveryLossTask() throws {
        let sut = DeviceManager(centralManager: centralManager)
        sut.bluetoothAvailable = true
        try sut.startDiscovery()
        XCTAssertNotNil(sut.discoveryLossTask)
    }

    func testStopDiscoveryCancelsTask() throws {
        let sut = DeviceManager(centralManager: centralManager)
        sut.bluetoothAvailable = true
        try sut.startDiscovery()
        sut.stopDiscovery()
        XCTAssertTrue(sut.discoveryLossTask?.isCancelled ?? false)
    }

    func testRetryAttemptsStartsAtZero() {
        let sut = DeviceManager(centralManager: centralManager)
        XCTAssertEqual(sut.retryAttempts, 0)
    }
}

// swiftlint:enable force_cast
