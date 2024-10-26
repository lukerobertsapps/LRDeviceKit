//
//  LRDeviceKit.swift
//  SwiftLockDeviceKit
//
//  Created by Luke Roberts on 25/10/2024.
//

import Foundation

/// Used to setup the library such as setting the available features etc
public final class LRDeviceKit {

    /// Shared singleton instance
    public static let shared = LRDeviceKit()

    private var config: Configuration?

    var configuration: Configuration {
        if let config { return config }
        return Configuration.defaultConfiguration
    }

    private init() { }
    
    /// Initial setup of the library with a configuration object
    /// - Parameter configuration: The configuration to use
    public func setup(with configuration: Configuration) {
        self.config = configuration
    }
}

/// MARK: Configuration Object

extension LRDeviceKit {
    public struct Configuration {

        /// The UUID of the BLE service containing the two characteristics
        let serviceUUIDString: String
        /// The UUID of the BLE characteristic for sending requests to
        let requestUUIDString: String
        /// The UUID of the BLE characteristic that the device replies on
        let replyUUIDString: String
        /// The 2-byte company identifier in the advert data
        let companyIdentifier: Data
        /// A list of features the device supports
        let features: [Feature.Type]
        
        /// Creates a new configuration object
        /// - Parameters:
        ///   - serviceUUIDString: The UUID of the BLE service containing the two characteristics
        ///   - requestUUIDString: The UUID of the BLE characteristic for sending requests to
        ///   - replyUUIDString: The UUID of the BLE characteristic that the device replies on
        ///   - companyIdentifier: The 2-byte company identifier in the advert data
        ///   - features: A list of features the device supports
        public init(
            serviceUUIDString: String,
            requestUUIDString: String,
            replyUUIDString: String,
            companyIdentifier: Data,
            features: [Feature.Type]
        ) {
            self.serviceUUIDString = serviceUUIDString
            self.requestUUIDString = requestUUIDString
            self.replyUUIDString = replyUUIDString
            self.companyIdentifier = companyIdentifier
            self.features = features
        }
    }
}

// MARK: Default Configuration Values

extension LRDeviceKit.Configuration {
    
    /// The default configuration for the library (Used in SwiftLock)
    static var defaultConfiguration: Self {
        return Self(
            serviceUUIDString: "00000000-9f34-11ee-8c90-0242ac120002",
            requestUUIDString: "00000001-9f34-11ee-8c90-0242ac120002",
            replyUUIDString: "00000002-9f34-11ee-8c90-0242ac120002",
            companyIdentifier: Data([0xFF, 0xFF]),
            features: [
                NameFeature.self,
                WifiFeature.self,
                AutoLockFeature.self,
                KeyExchangeFeature.self,
                PasswordFeature.self,
                LockFeature.self,
                SetUserFeature.self,
                GuestFeature.self,
                ResetFeature.self
            ]
        )
    }
}
