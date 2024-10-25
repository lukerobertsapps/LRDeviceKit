//
//  UUIDs.swift
//
//
//  Created by Luke Roberts on 21/01/2024.
//

import CoreBluetooth

// Define UUIDs as static properties on the CBUUID type so easier to use
extension CBUUID {

    /// The UUID for the lock service
    static let serviceUUID = CBUUID(string: LRDeviceKit.shared.configuration.serviceUUIDString)

    /// The UUID for the request characteristic
    static let requestUUID = CBUUID(string: LRDeviceKit.shared.configuration.requestUUIDString)

    /// The UUID for the reply characteristic
    static let replyUUID = CBUUID(string: LRDeviceKit.shared.configuration.replyUUIDString)
}
