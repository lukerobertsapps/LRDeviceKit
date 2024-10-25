//
//  MockPeripheral.swift
//
//
//  Created by Luke Roberts on 22/01/2024.
//

import Foundation
import CoreBluetoothMock

// Mock characteristics
extension CBMCharacteristicMock {
    static let requestCharacteristic = CBMCharacteristicMock(type: .requestUUID, properties: [.write])
    static let replyCharacteristic = CBMCharacteristicMock(type: .replyUUID, properties: [.notify])
}

// Mock service
extension CBMServiceMock {
    static let primarySerice = CBMServiceMock(
        type: .serviceUUID,
        primary: true,
        characteristics: .requestCharacteristic, .replyCharacteristic
    )
}

// Mock Peripheral
class MockPeripheral {

    private let manufacturerData: [UInt8] = [
        0xFF, 0xFF, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99
    ]

    var peripheral: CBMPeripheralSpec {
        CBMPeripheralSpec
          .simulatePeripheral(proximity: .immediate)
          .allowForRetrieval()
          .advertising(
            advertisementData: [
              CBMAdvertisementDataLocalNameKey: "Mock",
              CBMAdvertisementDataServiceUUIDsKey: [CBUUID.serviceUUID],
              CBMAdvertisementDataIsConnectable: true as NSNumber,
              CBAdvertisementDataManufacturerDataKey: Data(manufacturerData)
            ],
            withInterval: 0.25,
            alsoWhenConnected: false
          )
          .connectable(
            name: "Mock",
            services: [.primarySerice],
            delegate: MockPeripheralSpec(),
            connectionInterval: 0,
            mtu: 23
          )
          .build()
    }
}

class MockPeripheralSpec: CBMPeripheralSpecDelegate {
}
