//
//  Handler.swift
//
//
//  Created by Luke Roberts on 31/01/2024.
//

import Foundation

/// Outlines a handler, designed to bridge the gap between a feature and a transport
public protocol Handler {

    /// The transport used to send the data through
    var transport: Transport { get }

    /// Asynchronously sends transportable data and returns a reply
    /// - Parameter data: The transportable data to send
    /// - Returns: The reply transportable data
    @discardableResult
    func send(_ data: Transportable) async throws -> Transportable
}
