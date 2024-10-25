//
//  GuestFeature.swift
//
//
//  Created by Luke Roberts on 10/03/2024.
//

import Foundation

/// Feature allowing guests to access the device using a one time password
public final class GuestFeature: Feature {

    /// Unlocks the device using a one time password
    /// - Parameter otp: The one time password to use
    public func unlock(value: Bool, with otp: String, otpID: String) async throws {
        let boolData = value.data
        let separator = String(UnicodeScalar(31))
        let fullString = otp + separator + otpID
        var payload = fullString.data(using: .utf8)
        payload?.insert(boolData, at: 0)
        let message = Message(command: .guestUnlock, payload: payload)
        logger.info("Guest unlocking device")
        let reply = try await handler.send(message)
        if reply.payload == Data([0x00]) {
            throw GuestFeatureError.otpFailed
        }
    }

    enum GuestFeatureError: Error {
        case otpFailed
    }
}
