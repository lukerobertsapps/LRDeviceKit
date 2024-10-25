//
//  SecureStorage.swift
//  
//
//  Created by Luke Roberts on 09/02/2024.
//

import Foundation
import KeychainAccess
import CryptoKit

/// Helper class for securely storing data
public protocol SecureStorage {

    /// Saves the symmetric key to the keychain
    /// - Parameter symmetricKey: The key to save
    func save(symmetricKey: SymmetricKey) throws

    /// Fetches the symmetric key from the keychain
    /// - Returns: The symmetric key, nil if not found
    func retrieveSymmetricKey() -> SymmetricKey?

    /// Saves the device password to the keychain
    /// - Parameter devicePassword: The password to save
    func save(devicePassword: String) throws

    /// Fetches the device password from the keychain
    /// - Returns: The device password, nil if not found
    func retrieveDevicePassword() -> String?
}
