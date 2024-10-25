//
//  KeychainSecureStorage.swift
//
//
//  Created by Luke Roberts on 11/03/2024.
//

import Foundation
import KeychainAccess
import CryptoKit

public final class KeychainSecureStorage: SecureStorage {

    private let keychain = Keychain(service: "swiftlock-service")

    public init() { }

    public func save(symmetricKey: SymmetricKey) throws {
        let keyData = symmetricKey.withUnsafeBytes { Data($0) }
        let stringRepresentation = keyData.base64EncodedString()
        try keychain.set(stringRepresentation, key: SecureStorageKey.symmetricKey)
    }

    public func retrieveSymmetricKey() -> SymmetricKey? {
        guard
            let keyString = try? keychain.get(SecureStorageKey.symmetricKey),
            let data = Data(base64Encoded: keyString)
        else {
            return nil
        }
        return SymmetricKey(data: data)
    }

    public func save(devicePassword: String) throws {
        try keychain.set(devicePassword, key: SecureStorageKey.devicePassword)
    }

    public func retrieveDevicePassword() -> String? {
        try? keychain.get(SecureStorageKey.devicePassword)
    }
}
