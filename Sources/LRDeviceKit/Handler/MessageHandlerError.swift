//
//  MessageHandlerError.swift
//
//
//  Created by Luke Roberts on 02/02/2024.
//

import Foundation

/// An error that can be thrown from the message handler
enum MessageHandlerError: Error {

    /// The data attempted to be sent over the transport is not a valid message
    case invalidTransportableData

    /// The message received back is not a reply
    case invalidMessageType

    /// Too much time passed between sending a request and receiving a reply
    case timeout
}
