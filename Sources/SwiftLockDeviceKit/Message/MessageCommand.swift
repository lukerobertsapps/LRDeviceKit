//
//  MessageCommand.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

/// A command for a message
///
/// Made up of two bytes:
///     - 1: Represents the command
///     - 2: Represents the namespace the command belongs to
enum MessageCommand: UInt16 {

    // Device Settings Namespace (0x01)

    case setName = 0x0101
    case getName = 0x0201
    case setAutoLock = 0x0301
    case getAutoLock = 0x0401
    case setUserID = 0x0501
    case reset = 0x0601

    // Wifi Network Namespace (0x02)

    case startNetworkListen = 0x0102
    case stopNetworkListen = 0x0202
    case networkSSIDUpdate = 0x0302
    case connectToNetwork = 0x0402

    // Key Exchange and Encryption Namespace (0x03)

    case keyExchange = 0x0103
    case setDevicePassword = 0x0203

    // Normal Usage Namespace (0x04)

    case getLockState = 0x0104
    case setLockState = 0x0204

    // Guest Usage Namespace (0x05)

    case guestUnlock = 0x0105
}
