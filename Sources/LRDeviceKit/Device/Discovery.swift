//
//  Discovery.swift
//
//
//  Created by Luke Roberts on 26/01/2024.
//

import Foundation

/// Represents a device that has been discovered but not connected to
public class Discovery {

    /// The advertised name of the discovery
    public let name: String
    /// The advertised serial number of the discovery
    public let serial: String

    /// The peripheral the discovery represents
    let peripheral: CBPeripheral

    /// Optional initialiser for a discovery
    ///
    /// If the advert data is malformed, reject the discovery by returning nil
    /// - Parameters:
    ///   - peripheral: The peripheral used to create the discovery
    ///   - advertData: The advert data to check if the discovery is valid
    init?(peripheral: CBPeripheral, advertData: [String: Any]) {
        // The section of advert data that contains the company identifier
        let companyIndex = 0...1
        // The section of advert data that contains the device serial number
        let serialNumberIndex = 2...7
        // Check company index
        guard
            let manufacturerData = advertData[CBAdvertisementDataManufacturerDataKey] as? Data,
            manufacturerData[companyIndex] == LRDeviceKit.shared.configuration.companyIdentifier
        else {
            return nil
        }
        self.name = peripheral.name ?? ""
        self.serial = manufacturerData[serialNumberIndex].stringRepresentation
        self.peripheral = peripheral
    }
}

// MARK: Protocol Conformance

extension Discovery: Hashable, Equatable, Identifiable {
    public static func == (lhs: Discovery, rhs: Discovery) -> Bool {
        // Two discoveries are equal if their peripheral identifiers are the same
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(peripheral.identifier)
    }
}
