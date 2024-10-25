//
//  NameFeature.swift
//
//
//  Created by Luke Roberts on 03/02/2024.
//

import Foundation

private let maximumNameLength = 20

/// Feature for getting and setting the device's name
public final class NameFeature: Feature {

    /// Sets the device name to the supplied value
    /// - Parameter name: The name to set the peripheral to
    public func setName(to name: String) async throws {
        // Remove any excess characters to ensure name is 20 characters
        let clippedName = name.prefix(maximumNameLength)
        // Convert string into data and send to handler
        let payload = clippedName.data(using: .utf8)
        let message = Message(command: .setName, payload: payload)
        logger.info("Setting device name to: \(clippedName)")
        try await handler.send(message)
    }
}
