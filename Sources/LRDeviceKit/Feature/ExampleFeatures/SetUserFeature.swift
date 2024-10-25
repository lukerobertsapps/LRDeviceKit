//
//  SetUserFeature.swift
//
//
//  Created by Luke Roberts on 23/02/2024.
//

import Foundation

/// Feature for setting the user id for the owner of the device
public final class SetUserFeature: Feature {

    /// Registers a new User ID for the device
    /// - Parameter user: The user ID
    public func register(user: String) async throws {
        let payload = user.data(using: .utf8)
        let message = Message(command: .setUserID, payload: payload)
        logger.info("Setting user id for device: \(user)")
        try await handler.send(message)
    }
}
