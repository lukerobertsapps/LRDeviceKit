//
//  Device.swift
//
//
//  Created by Luke Roberts on 31/01/2024.
//

import Foundation

/// Represents a device containing features
public class Device {

    /// The name of the device
    public var name: String {
        discovery.name
    }

    /// The serial number
    public var serial: String {
        discovery.serial
    }

    /// A list of available features for the device providing functionality
    public var features: [Feature]

    /// The discovery used to create this device
    let discovery: Discovery

    /// Initialises a device from a discovery
    /// - Parameters:
    ///   - discovery: The discovery used to create the device
    ///   - features: A list of features the device supports
    init(discovery: Discovery, features: [Feature]) {
        self.discovery = discovery
        self.features = features
    }

    /// Generic helper method to return a device feature
    /// - Returns: The feature requested
    public func feature<T: Feature>() -> T? {
        features.first(where: { $0 is T }) as? T
    }
}

extension Device: Equatable {
    public static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.discovery.serial == rhs.discovery.serial
    }
}
