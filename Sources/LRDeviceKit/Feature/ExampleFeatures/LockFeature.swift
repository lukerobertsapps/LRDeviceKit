//
//  LockFeature.swift
//
//
//  Created by Luke Roberts on 10/02/2024.
//

import Foundation
import CryptoKit

/// Feature used to get the state of the lock and to lock / unlock
public final class LockFeature: Feature {

    public enum LockState: UInt8 {
        case locked = 0x00
        case unlocked = 0x01

        init(_ data: Data) {
            self = data == Data([0x01]) ? .unlocked : .locked
        }
    }

    /// Gets the state of the lock
    /// - Returns: true if lock unlocked, false if locked
    public func getLockState() async throws -> LockState {
        // Create and send message
        logger.info("Getting lock state")
        let message = Message(command: .getLockState)
        let reply = try await handler.send(message)
        // Return a lock state based on the reply payload
        let lockState = LockState(reply.payload ?? Data())
        logger.info("Returned lock state: \(lockState.rawValue)")
        return lockState
    }

    /// Locks and unlocks the device
    /// - Parameters:
    ///   - value: The lock state to set, either locked or unlocked
    ///   - storage: The secure storage used to fetch the device password and key
    public func setLock(
        to value: LockState,
        storage: SecureStorage = SecureStorageFactory.instance()
    ) async throws {
        logger.info("Setting lock state to: \(value.rawValue)")
        // Get device password
        guard let password = storage.retrieveDevicePassword()?.data(using: .utf8) else {
            throw LockFeatureError.missingPassword
        }
        // Get encryption key
        guard let encryptionKey = storage.retrieveSymmetricKey() else {
            throw LockFeatureError.missingKey
        }
        // Encrypt with nonce
        logger.info("Encrypting device password for payload")
        let nonce = AES.GCM.Nonce()
        let sealed = try AES.GCM.seal(password, using: encryptionKey, nonce: nonce)
        let encryptedPayload = sealed.combined

        // Create and send message
        logger.info("Setting lock state to: \(value.rawValue)")
        let payload = value.rawValue.data + (encryptedPayload ?? Data())
        let message = Message(command: .setLockState, isEncrypted: true, payload: payload)
        let reply = try await handler.send(message)

        // Check if successful
        guard reply.payload == Data([0x01]) else {
            throw LockFeatureError.deviceRejectedPassword
        }
    }

    /// Different errors that can be thrown by the lock feature
    enum LockFeatureError: Error {
        case missingPassword
        case missingKey
        case deviceRejectedPassword
    }
}
