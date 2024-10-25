//
//  BLETransport.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation
import CoreBluetoothMock

/// Transport that sends and receives data using bluetooth low energy
class BLETransport: NSObject, Transport {

    var isReady: Bool {
        get async {
            async let servicesChecked = await servicesChecked()
            async let notificationsChecked = await notificationsChecked()
            let (services, notifications) = await (servicesChecked, notificationsChecked)
            return services && notifications
        }
    }

    var valueUpdated: AsyncStream<Data?> {
        AsyncStream { continuation in
            self.valueContinuation = continuation
        }
    }

    let peripheral: CBPeripheral
    var servicesChecked = 0
    var notificationsToCheck = 0
    var characteristics: [String: CBCharacteristic] = [:]

    private var servicesCheckedCompletion: ((Bool) -> Void)?
    private var notificationsSetCompletion: ((Bool) -> Void)?
    private var valueContinuation: AsyncStream<Data?>.Continuation?

    /// Creates a transport that uses Bluetooth Low-Energy
    /// - Parameter peripheral: The peripheral backing the transport
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        // Set the delegate so the transport can get peripheral updates
        peripheral.delegate = self
        // Discover every available service for the peripheral as soon as transport created
        peripheral.discoverServices(nil)
    }

    deinit {
        // Cancel the async stream when object is deinitialised
        // to ensure the object is freed up in memory
        valueContinuation?.finish()
    }

    func send(data: Data, using uuid: String) {
        // Get characteristic for the UUID passed in
        guard let characteristic = characteristics[uuid] else {
            logger.warning("No characteristic found for \(uuid), cannot send data")
            return
        }
        // Send the data to the peripheral, ensuring a response will be provided
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    // MARK: Concurrency wrappers

    private func servicesChecked() async -> Bool {
        await withCheckedContinuation { continuation in
            servicesCheckedCompletion = { continuation.resume(returning: $0) }
        }
    }

    private func notificationsChecked() async -> Bool {
        await withCheckedContinuation { continuation in
            notificationsSetCompletion = { continuation.resume(returning: $0) }
        }
    }
}

// MARK: Peripheral Delegate Methods

extension BLETransport: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBMPeripheral, didDiscoverServices error: Error?) {
        // Error handling
        guard let services = peripheral.services, error == nil else {
            logger.warning("Failed finding services for peripheral: \(error)")
            servicesCheckedCompletion?(false)
            return
        }
        logger.debug("Found \(services.count) services for peripheral: \(peripheral.identifier)")
        // Discover all characteristics for all services
        for service in services {
            service.peripheral?.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(
        _ peripheral: CBMPeripheral,
        didDiscoverCharacteristicsFor service: CBMService,
        error: Error?
    ) {
        // Error handling
        guard let characteristics = service.characteristics, error == nil else {
            logger.warning("Failed to discovery characteristics: \(error)")
            servicesCheckedCompletion?(false)
            return
        }
        for characteristic in characteristics {
            // Save a reference to a characteristic against an ID so it can
            // be used later
            self.characteristics[characteristic.uuid.uuidString] = characteristic
            // Find all characteristics with notify and enable it
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                // Increment notification counter to keep track
                notificationsToCheck += 1
            }
        }
        // Increment service counter to track which services have been discovered
        servicesChecked += 1
        // If all services discovered, announce
        if servicesChecked == peripheral.services?.count {
            servicesCheckedCompletion?(true)
        }
    }

    func peripheral(
        _ peripheral: CBMPeripheral,
        didUpdateNotificationStateFor characteristic: CBMCharacteristic,
        error: Error?
    ) {
        // Error handling
        if let error = error {
            logger.warning("Failed to set notify for characteristic: \(characteristic.uuid): \(error)")
            notificationsSetCompletion?(false)
        }
        // Decrement notification counter as this has been set
        notificationsToCheck -= 1
        if notificationsToCheck == 0 {
            // Found all characteristics with notifications
            notificationsSetCompletion?(true)
        }
    }

    func peripheral(
        _ peripheral: CBMPeripheral,
        didUpdateValueFor characteristic: CBMCharacteristic,
        error: Error?
    ) {
        // Check there's data attached to the characteristic
        guard let data = characteristic.value else {
            logger.warning("Characteristic: \(characteristic.uuid) sent no data")
            return
        }
        // Notify the async sequence of the data
        valueContinuation?.yield(data)
    }
}
