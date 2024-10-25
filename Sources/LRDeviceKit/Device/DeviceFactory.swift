//
//  DeviceFactory.swift
//
//
//  Created by Luke Roberts on 02/02/2024.
//

import Foundation


/// Factory class to instantiate devices
class DeviceFactory {

    /// Creates a device from a discovery and a transport
    /// - Parameters:
    ///   - discovery: The discovery containing the underlying peripheral
    ///   - transport: The transport to use for device communication
    /// - Returns: A device instance
    static func create(using discovery: Discovery, and transport: Transport) -> Device {
        let messageHandler = MessageHandler(transport: transport)
        let features = LRDeviceKit.shared.configuration.features.map { $0.init(handler: messageHandler) }
        return Device(discovery: discovery, features: features)
    }
}
