//
//  ResetFeature.swift
//
//
//  Created by Luke Roberts on 10/03/2024.
//

import Foundation

/// Feature to reset the device
public final class ResetFeature: Feature {

    /// Resets the device
    public func reset() async throws {
        let message = Message(command: .reset)
        try await handler.send(message)
    }
}
