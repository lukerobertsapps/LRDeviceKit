//
//  MessageType.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

/// The type of message
public enum MessageType: UInt8 {

    /// A message type requesting data
    case request = 0x01

    /// A message type replying to a request
    case reply = 0x02

    /// A message that isn't a direct reply to a request
    case notification = 0x03
}
