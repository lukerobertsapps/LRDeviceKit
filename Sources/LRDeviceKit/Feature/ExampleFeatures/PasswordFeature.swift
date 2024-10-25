//
//  PasswordFeature.swift
//
//
//  Created by Luke Roberts on 10/02/2024.
//

import Foundation
import CryptoKit

/// Feature responsible for generating and setting the password for the device
public final class PasswordFeature: Feature {

    /// Different types of errors the password feature can throw
    enum PasswordFeatureError: Error {
        case couldNotGeneratePassword
        case noSymmetricKey
        case deviceRejectedPasswordRequest
    }

    /// Generates and sets a password for the device
    /// - Parameters:
    ///   - key: The symmetric key to use for encryption, use nil if fetching from storage
    ///   - secureStorage: The secure storage to use for fetching and saving secure data
    public func generateDevicePassword(
        with key: SymmetricKey? = nil,
        secureStorage: SecureStorage = SecureStorageFactory.instance()
    ) async throws {
        // Generate a unique password
        logger.info("Generating device password")
        let password = UUID().uuidString
        guard let passwordData = password.data(using: .utf8) else {
            throw PasswordFeatureError.couldNotGeneratePassword
        }

        // Get the key if not provided
        guard let symmetricKey = key ?? secureStorage.retrieveSymmetricKey() else {
            throw PasswordFeatureError.noSymmetricKey
        }

        // Encrypt the password using the symmetric key
        logger.info("Encrypting device password")
        let nonce = AES.GCM.Nonce()
        let sealed = try AES.GCM.seal(passwordData, using: symmetricKey, nonce: nonce)
        let encryptedPayload = sealed.combined

        // Create and send the message
        logger.info("Sending device password")
        let message = Message(command: .setDevicePassword, isEncrypted: true, payload: encryptedPayload)
        let reply = try await handler.send(message)

        // Check if reply is success
        guard reply.payload == Data([0x01]) else {
            throw PasswordFeatureError.deviceRejectedPasswordRequest
        }

        // If successful, securely store the password for later use
        logger.info("Saving device password")
        try secureStorage.save(devicePassword: password)
    }
}
