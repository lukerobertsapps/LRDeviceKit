//
//  DeviceManagerSettings.swift
//
//
//  Created by Luke Roberts on 26/01/2024.
//

import Foundation

/// Object holding all settings / constants for the device manager
struct DeviceManagerSettings {

    /// The amount of time needed to pass to mark a discovery as lost
    var discoveryLossTimeout: TimeInterval = 5

    /// The maximum amount of connection retry attempts
    var retryAttempts: Int = 3

    /// The allowed time for the connection process
    var connectionTimeoutDuration: TimeInterval = 15
}
