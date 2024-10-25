//
//  Array+Discovery.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

extension Array where Element == Discovery {

    /// Returns a discovery for a given peripheral
    /// - Parameter peripheral: The peripheral used to perform the search
    /// - Returns: A discovery containing the given peripheral
    func discovery(for peripheral: CBPeripheral) -> Discovery? {
        self.first(where: { $0.peripheral.identifier == peripheral.identifier })
    }

    /// Removes all discoveries matching a given uuid
    /// - Parameter uuid: The uuid to check
    mutating func removeAll(matching uuid: UUID) {
        removeAll(where: { $0.peripheral.identifier == uuid })
    }
}
