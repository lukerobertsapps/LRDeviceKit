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
    static let serviceUUID = CBUUID(string: "00000000-9f34-11ee-8c90-0242ac120002")

    /// The UUID for the request characteristic
    static let requestUUID = CBUUID(string: "00000001-9f34-11ee-8c90-0242ac120002")

    /// The UUID for the reply characteristic
    static let replyUUID = CBUUID(string: "00000002-9f34-11ee-8c90-0242ac120002")
}
