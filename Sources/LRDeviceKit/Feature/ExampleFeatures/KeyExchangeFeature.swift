//
//  KeyExchangeFeature.swift
//
//
//  Created by Luke Roberts on 09/02/2024.
//

import Foundation
import CryptoKit

private let info = "smartlockperipheral"
private let salt = "9iac7i7zikocotce9gn3ji7lztz8rltn"

/// Feature used to perform a key exchange and derive a shared symmetric key
public final class KeyExchangeFeature: Feature {

    /// Performs a cryptographic key exchange to derive a symmetric key
    /// - Returns: The derived symmetric key
    /// - Parameter storage: The storage to use to persist the key
    @discardableResult
    public func performKeyExchange(
        storage: SecureStorage = SecureStorageFactory.instance()
    ) async throws -> SymmetricKey {
        // Generate a private key
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        // Generate a public key
        let publicKey = privateKey.publicKey

        // Send public key to device and receive device's key back
        logger.info("Sending public key to device")
        let message = Message(command: .keyExchange, payload: publicKey.rawRepresentation)
        let reply = try await handler.send(message)

        // Get returned payload data
        guard let payloadData = reply.payload else {
            throw KeyExchangeFeatureError.deviceRejectedRequest
        }

        logger.info("Received public key from device")
        // Create a public key from the payload data
        let externalPublicKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: payloadData)
        // Generate a shared secret using our private key and their public key
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: externalPublicKey)

        // Attempt to derive a symmetric key
        logger.info("Deriving symmetric key")
        let symmetricKey = try deriveKey(from: sharedSecret)

        // Save the derived key to secure storage
        logger.info(("Saving key to keychain"))
        try storage.save(symmetricKey: symmetricKey)

        // Return symmetric key
        return symmetricKey
    }

    private func deriveKey(from sharedSecret: SharedSecret) throws -> SymmetricKey {
        // Convert the info and salt into data using utf8
        guard let info = info.data(using: .utf8), let salt = salt.data(using: .utf8) else {
            throw KeyExchangeFeatureError.couldNotEncodeSalt
        }
        // Derive the symmetric key using SHA256
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: info,
            outputByteCount: 32
        )
    }

    /// Represents an error that the key exchange feature can throw
    enum KeyExchangeFeatureError: Error {
        case deviceRejectedRequest
        case couldNotEncodeSalt
    }
}
