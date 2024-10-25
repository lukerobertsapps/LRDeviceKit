//
//  SecureStorageFactory.swift
//
//
//  Created by Luke Roberts on 11/03/2024.
//

import Foundation

/// Factory class that returns an instance of a secure storage object
public final class SecureStorageFactory {

    public static func instance() -> SecureStorage {
        // TODO: Replace insecure user defaults storage with secure keychain storage.
        // This is possible iOS 15.4+ but no clear way to do it
        // https://developer.apple.com/documentation/app_clips/sharing_data_between_your_app_clip_and_your_full_app

        // KeychainSecureStorage()
        UserDefaultsSecureStorage()
    }
}
