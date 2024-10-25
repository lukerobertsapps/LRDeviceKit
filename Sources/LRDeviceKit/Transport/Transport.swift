//
//  Transport.swift
//
//
//  Created by Luke Roberts on 26/01/2024.
//

import Foundation
import CoreBluetoothMock

/// Represents a generic transport layer used to send data
public protocol Transport: NSObject {

    /// Asynchronously determines if the transport is ready for use
    var isReady: Bool { get async }

    /// Updates when the transport receives data
    var valueUpdated: AsyncStream<Data?> { get }

    /// Sends data over the transport
    /// - Parameters:
    ///   - data: The data to send
    ///   - uuid: The identifier to use to determine where to send the data to
    func send(data: Data, using uuid: String)
}
