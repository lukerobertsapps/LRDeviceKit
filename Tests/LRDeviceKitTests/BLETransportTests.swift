//
//  BLETransportTests.swift
//  
//
//  Created by Luke Roberts on 27/01/2024.
//

import XCTest
import CoreBluetoothMock
@testable import SwiftLockDeviceKit

final class BLETransportTests: XCTestCase {

    var mockPeripheral: CBMPeripheralSpec!
    var mockCentralManager: CBCentralManager!

    override func setUp() {
      mockPeripheral = MockPeripheral().peripheral
      CBMCentralManagerMock.simulateInitialState(.poweredOff)
      CBMCentralManagerMock.simulatePeripherals([mockPeripheral])
      CBMCentralManagerMock.simulatePowerOn()
      mockCentralManager = CBCentralManagerFactory.instance(forceMock: true)
    }

    private func peripheral() -> CBPeripheral {
      let delegate = CBMCentralManagerDelegateProxy()
      let managerPoweredOn = XCTestExpectation(description: "Powered On")
      let manager = CBMCentralManagerMock(delegate: delegate, queue: nil)
      delegate.didUpdateState = { _ in managerPoweredOn.fulfill() }
      wait(for: [managerPoweredOn], timeout: 1)
      let peripherals = manager.retrievePeripherals(withIdentifiers: [mockPeripheral.identifier])
      return peripherals.first!
    }

    func testPeripheralDelegateGetsSetOnInit() {
        let peripheral = peripheral()
        let sut = BLETransport(peripheral: peripheral)
        XCTAssertEqual(peripheral.delegate as? BLETransport, sut)
    }

    func testServicesCheckedStartsAtZero() {
        let peripheral = peripheral()
        let sut = BLETransport(peripheral: peripheral)
        XCTAssertEqual(sut.servicesChecked, 0)
    }

    func testNotificationsToCheckStartsAtZero() {
        let peripheral = peripheral()
        let sut = BLETransport(peripheral: peripheral)
        XCTAssertEqual(sut.notificationsToCheck, 0)
    }
}
