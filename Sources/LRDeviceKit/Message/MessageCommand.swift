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
struct MessageCommand: RawRepresentable, Hashable {
    let rawValue: UInt16

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

// MARK: Example Commands
extension MessageCommand {

    // Device Settings Namespace (0x01)
    static let setName = MessageCommand(rawValue: 0x0101)
    static let getName = MessageCommand(rawValue: 0x0201)
    static let setAutoLock = MessageCommand(rawValue: 0x0301)
    static let getAutoLock = MessageCommand(rawValue: 0x0401)
    static let setUserID = MessageCommand(rawValue: 0x0501)
    static let reset = MessageCommand(rawValue: 0x0601)

    // Wifi Network Namespace (0x02)
    static let startNetworkListen = MessageCommand(rawValue: 0x0102)
    static let stopNetworkListen = MessageCommand(rawValue: 0x0202)
    static let networkSSIDUpdate = MessageCommand(rawValue: 0x0302)
    static let connectToNetwork = MessageCommand(rawValue: 0x0402)

    // Key Exchange and Encryption Namespace (0x03)
    static let keyExchange = MessageCommand(rawValue: 0x0103)
    static let setDevicePassword = MessageCommand(rawValue: 0x0203)

    // Normal Usage Namespace (0x04)
    static let getLockState = MessageCommand(rawValue: 0x0104)
    static let setLockState = MessageCommand(rawValue: 0x0204)

    // Guest Usage Namespace (0x05)
    static let guestUnlock = MessageCommand(rawValue: 0x0105)
}
