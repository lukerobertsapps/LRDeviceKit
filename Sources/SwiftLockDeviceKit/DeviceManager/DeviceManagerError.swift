//
//  DeviceManagerError.swift
//
//
//  Created by Luke Roberts on 21/01/2024.
//

import Foundation

/// Represents various errors the device manager can throw
enum DeviceManagerError: Error {

    /// Thrown when bluetooth is not available
    case bluetoothUnavailable

    /// Thrown when the connection to the discovery fails
    case failedToConnect

    /// Thrown when a connection to a discovery takes too long
    case connectionTimedOut
}
