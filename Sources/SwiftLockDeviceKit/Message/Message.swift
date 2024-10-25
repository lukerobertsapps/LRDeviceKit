//
//  Message.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

/// Represents a message that can be sent to and from a device
struct Message: Transportable {

    /// The type of message
    let type: MessageType
    /// Which command is represented by the message
    let command: MessageCommand
    /// Whether the message contains an encrypted payload
    let isEncrypted: Bool
    /// The main contents of the message
    let payload: Data?

    /// Creates a new message
    /// - Parameters:
    ///   - type: The type of message, request by default
    ///   - command: The command for the message
    ///   - isEncrypted: Whether the message is encrypted, false by default
    ///   - payload: The contents of the message
    init(
        type: MessageType = .request,
        command: MessageCommand,
        isEncrypted: Bool = false,
        payload: Data? = nil
    ) {
        self.type = type
        self.command = command
        self.isEncrypted = isEncrypted
        self.payload = payload
    }

    init?(from data: Data) {
        if
            data.count >= 5,
            let messageType: UInt8 = data[1..<2].typeConverted(),
            let messageCommand: UInt16 = data[2..<4].typeConverted(),
            let isEncrypted: Bool = data[4..<5].typeConverted(),
            let type = MessageType(rawValue: messageType),
            let command = MessageCommand(rawValue: messageCommand.bigEndian)
        {
            self.type = type
            self.command = command
            self.isEncrypted = isEncrypted
            var payloadData: Data?
            let payloadRange = 5...
            if data.count > 5 {
              payloadData = data[payloadRange]
            }
            self.payload = payloadData
        } else {
            return nil
        }
    }

    func pack() -> Data {
        var packedData = Data()
        packedData.append(type.rawValue)
        packedData.append(command.rawValue.bigEndian.data)
        packedData.append(isEncrypted.data)
        if let payload = payload { packedData.append(payload) }
        packedData.insert(contentsOf: UInt8(packedData.count + 1).data, at: 0)
        return packedData
    }
}
