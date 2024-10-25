//
//  LRDeviceKit.swift
//  SwiftLockDeviceKit
//
//  Created by Luke Roberts on 25/10/2024.
//

/// Entry point into LRDeviceKit
///
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

    func setup(with configuration: Configuration) {
        self.config = configuration
    }
}

/// MARK: Configuration Object

extension LRDeviceKit {
    struct Configuration {
        let serviceUUIDString: String
        let requestUUIDString: String
        let replyUUIDString: String
        let features: [Feature.Type]
    }
}

// MARK: Default Configuration Values

extension LRDeviceKit.Configuration {
    
    static var defaultConfiguration: Self {
        return Self(
            serviceUUIDString: "00000000-9f34-11ee-8c90-0242ac120002",
            requestUUIDString: "00000001-9f34-11ee-8c90-0242ac120002",
            replyUUIDString: "00000002-9f34-11ee-8c90-0242ac120002",
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
