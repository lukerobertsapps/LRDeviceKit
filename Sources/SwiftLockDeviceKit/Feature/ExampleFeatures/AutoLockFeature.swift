//
//  AutoLockFeature.swift
//
//
//  Created by Luke Roberts on 04/02/2024.
//

import Foundation

/// A feature for setting the auto lock setting
///
/// This is how long it takes for the lock to relock after unlocking
public final class AutoLockFeature: Feature {

    /// Sets the time for the lock to automatically lock after unlocking
    /// - Parameter time: The time, nil if no auto lock
    public func setAutoLock(time: Int?) async throws {
        var payload: Data?
        if let time {
            // If time has been passed in, make positive and truncate the data so it fits into 1 byte
            payload = UInt8(truncatingIfNeeded: abs(time)).data
        }
        logger.info("Setting auto lock to \(time ?? -1)")
        let message = Message(command: .setAutoLock, payload: payload)
        try await handler.send(message)
    }
}
