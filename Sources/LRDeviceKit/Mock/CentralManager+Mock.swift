//
//  CentralManager+Mock.swift
//
//
//  Created by Luke Roberts on 26/01/2024.
//

import CoreBluetoothMock

extension CBMCentralManagerMock {

    /// Helper function to start mocking a peripheral
    static func setupMock() {
        CBMCentralManagerMock.simulatePeripherals([MockPeripheral().peripheral])
        CBMCentralManagerMock.simulatePowerOn()
    }
}
