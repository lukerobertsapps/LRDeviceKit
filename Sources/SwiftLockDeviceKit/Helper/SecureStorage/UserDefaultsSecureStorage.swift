//
//  UserDefaultsSecureStorage.swift
//
//
//  Created by Luke Roberts on 11/03/2024.
//

import Foundation
import CryptoKit

/// User defaults implementation of secure storage
public final class UserDefaultsSecureStorage: SecureStorage {

    private let defaults = UserDefaults(suiteName: "group.co.lukeroberts.swiftlock")

    public func save(symmetricKey: SymmetricKey) throws {
        let keyData = symmetricKey.withUnsafeBytes { Data($0) }
        let stringRepresentation = keyData.base64EncodedString()
        defaults?.setValue(stringRepresentation, forKey: SecureStorageKey.symmetricKey)
    }

    public func retrieveSymmetricKey() -> SymmetricKey? {
        guard
            let string = defaults?.string(forKey: SecureStorageKey.symmetricKey),
            let data = Data(base64Encoded: string)
        else {
            return nil
        }
        return SymmetricKey(data: data)
    }

    public func save(devicePassword: String) throws {
        defaults?.setValue(devicePassword, forKey: SecureStorageKey.devicePassword)
    }

    public func retrieveDevicePassword() -> String? {
        defaults?.string(forKey: SecureStorageKey.devicePassword)
    }
}
