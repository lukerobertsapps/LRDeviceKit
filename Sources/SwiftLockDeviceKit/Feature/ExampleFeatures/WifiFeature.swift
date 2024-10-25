//
//  WifiFeature.swift
//
//
//  Created by Luke Roberts on 04/02/2024.
//

import Foundation

/// Feature for connecting the device to a wifi network
public final class WifiFeature: Feature {

    /// Connects to a wifi network using an ssid and password
    /// - Parameters:
    ///   - ssid: The wifi network's SSID
    ///   - password: The wifi network's password
    public func connect(with ssid: String, and password: String) async throws {
        // Create a separator character that cannot be present in either ssid or password
        let separator = String(UnicodeScalar(31))
        // Combine and convert to data
        let fullString = ssid + separator + password
        let payload = fullString.data(using: .utf8)
        logger.info("Connecting device to network: \(ssid)")
        let message = Message(command: .connectToNetwork, payload: payload)
        try await handler.send(message)
    }

    /// Gets all available nearby wifi network names
    /// - Returns: A list of all the SSIDs
    public func getAvailableNetworks() async throws -> [String] {
        let message = Message(command: .startNetworkListen)
        do {
            logger.info("Getting all available wifi networks")
            let reply = try await handler.send(message)
            if let payload = reply.payload, let allNetworks = String(data: payload, encoding: .utf8) {
                let networks = allNetworks.components(separatedBy: String(UnicodeScalar(31)))
                return networks.filter { !$0.isEmpty }
            } else {
                return []
            }
        } catch {
            logger.warning("Could not get networks")
            throw error
        }
    }
}
