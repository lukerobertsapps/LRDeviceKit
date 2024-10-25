//
//  DeviceManager.swift
//
//
//  Created by Luke Roberts on 21/01/2024.
//

import Foundation
import CoreBluetoothMock

/// Manager class acting as an entry point for all device interaction
///
/// This includes discovery and connection to a device
@Observable public final class DeviceManager: NSObject {

    /// The connected device
    public var device: Device?

    /// A list of all discovered devices
    public var discoveries: [Discovery] = []

    var bluetoothAvailable = false
    var discoveryTimestamps: [UUID: Date] = [:]
    var discoveryLossTask: Task<Void, Error>?
    var timeoutTask: Task<Void, Error>?
    var connectionTask: Task<Void, Never>?
    var connectionContinuation: CheckedContinuation<Void, Error>?
    var retryAttempts = 0
    var serialNumber: String?

    let centralManager: CBCentralManager
    let settings: DeviceManagerSettings

    public convenience init(shouldMock: Bool = false) {
        if shouldMock {
            // If device manager should mock, force the manager factory to return a mock
            CBMCentralManagerMock.setupMock()
            self.init(centralManager: CBCentralManagerFactory.instance(forceMock: true))
        } else {
            // Otherwise use the standard initialiser with a standard central manager instance
            self.init(centralManager: CBCentralManagerFactory.instance())
        }
    }

    /// Initialises the device manager
    /// - Parameter centralManager: The central manager used for device discovery
    /// - Parameter settings: Stores settings for the device manager
    init(centralManager: CBCentralManager, settings: DeviceManagerSettings = .init()) {
        // Assign the parameters
        self.centralManager = centralManager
        self.settings = settings
        // Need to initialise the NSObject this class inherits from
        super.init()
        // Set the central manager's delegate to self so device manager can receive delegate updates
        centralManager.delegate = self
    }

    /// Starts device discovery
    public func startDiscovery() throws {
        guard bluetoothAvailable else {
            logger.warning("Discovery started before bluetooth available")
            throw DeviceManagerError.bluetoothUnavailable
        }
        scanForPeripherals()
        checkForLostDiscoveries()
    }

    /// Stops device discovery
    public func stopDiscovery() {
        logger.info("Stopped discovery")
        centralManager.stopScan()
        discoveryLossTask?.cancel()
        discoveries.removeAll()
        discoveryTimestamps.removeAll()
    }

    /// Starts the connection process to a discovery
    /// - Parameter discovery: The discovery to connect to
    public func connect(to discovery: Discovery) async throws {
        logger.info("Connecting to discovery \(discovery.peripheral.identifier.uuidString)")
        discoveryLossTask?.cancel()
        retryAttempts = 0
        startConnectionTimeout()
        // Use continuation to make this method async
        return try await withCheckedThrowingContinuation { continuation in
            // Save a reference to the continuation so it can be resumed later
            connectionContinuation = continuation
            // Connect to the discovery's peripheral
            centralManager.connect(discovery.peripheral)
        }
    }

    /// Starts discovery and connects to a device matching a serial number
    /// - Parameter serialNumber: The serial number used to search
    public func connect(with serialNumber: String) async throws {
        logger.info("Attempting to find discovery with serial: \(serialNumber)")
        self.serialNumber = serialNumber
        try startDiscovery()
        startConnectionTimeout()
        return try await withCheckedThrowingContinuation { continuation in
            connectionContinuation = continuation
        }
    }

    /// Disconnects from any connected device
    public func disconnect() {
        guard let device else { return }
        centralManager.cancelPeripheralConnection(device.discovery.peripheral)
    }

    private func scanForPeripherals() {
        logger.info("Scanning for peripherals with service: \(CBUUID.serviceUUID)")
        // Scan for peripherals but only with the known service uuid
        // Allow duplicates so can track when a discovery has been lost or left area
        centralManager.scanForPeripherals(
            withServices: [.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    private func didConnect(to discovery: Discovery) {
        connectionTask = Task {
            logger.info("Creating BLE transport, waiting for it to be ready")
            // Create the transport with the peripheral and wait for transport to be ready
            let transport = BLETransport(peripheral: discovery.peripheral)
            let transportReady = await transport.isReady

            if transportReady {
                logger.info("BLE transport is ready, creating device")
                // Create the device using a factory
                self.device = DeviceFactory.create(using: discovery, and: transport)
                logger.info("Device created and ready for use")
                stopDiscovery()
                // Resume the continuation to notify the caller that the device was connected to
                connectionContinuation?.resume()
                connectionContinuation = nil
                timeoutTask?.cancel()
                serialNumber = nil
            } else {
                logger.warning("Failed to create BLE transport")
                connectionContinuation?.resume(throwing: DeviceManagerError.failedToConnect)
                connectionContinuation = nil
            }
        }
    }

    private func checkForLostDiscoveries() {
        discoveryLossTask = Task {
            try await Task.sleep(for: .seconds(settings.discoveryLossTimeout))
            validateLostDiscoveries()
        }
    }

    private func validateLostDiscoveries() {
        discoveryLossTask?.cancel()
        discoveryTimestamps.forEach { deviceUUID, timestamp in
            // If the time since the last scan has exceeded the timeout discovery is lost
            if Date.now.timeIntervalSince(timestamp) > settings.discoveryLossTimeout {
                logger.info("Lost discovery with identifier: \(deviceUUID)")
                discoveryTimestamps.removeValue(forKey: deviceUUID)
                discoveries.removeAll(where: { $0.peripheral.identifier == deviceUUID })
            }
        }
        checkForLostDiscoveries()
    }

    private func didLoseConnection(to peripheral: CBPeripheral) {
        // Check there's a connected device and it matches the peripheral
        guard let device, device.discovery.peripheral.identifier == peripheral.identifier else {
            logger.warning("Lost connection but no connected device, returning")
            return
        }
        logger.info("Lost connection to connected device: \(peripheral.identifier)")
        discoveries.removeAll(matching: peripheral.identifier)
        self.device = nil
    }

    private func startConnectionTimeout() {
        // Start a task for the duration of the timeout
        timeoutTask = Task {
            try await Task.sleep(for: .seconds(settings.connectionTimeoutDuration))
            // Call did timeout if the task succeeds
            didTimeout()
        }
    }

    private func didTimeout() {
        for discovery in discoveries {
            centralManager.cancelPeripheralConnection(discovery.peripheral)
        }
        stopDiscovery()
        serialNumber = nil
        // Cancel all connection activity
        connectionTask?.cancel()
        // Throw an error
        connectionContinuation?.resume(throwing: DeviceManagerError.connectionTimedOut)
        logger.warning("Connection timed out")
    }
}

// MARK: - Central Manager Delegate

extension DeviceManager: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothAvailable = central.state == .poweredOn
        logger.info("Central manager state changed to: \(central.state.rawValue)")
    }

    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        // Mark the peripheral as being discovered / rediscovered
        discoveryTimestamps[peripheral.identifier] = .now

        // New discovery so add to discoveries array
        if let discovery = Discovery(peripheral: peripheral, advertData: advertisementData),
           !discoveries.contains(discovery) {
            logger.info("Did discover peripheral with id: \(peripheral.identifier.uuidString)")
            discoveries.append(discovery)

            // If a serial number has been set, auto connect
            if let serialNumber, serialNumber == discovery.serial {
                logger.info("Found discovery with serial: \(serialNumber))")
                centralManager.connect(discovery.peripheral)
            }
        }
    }

    public func centralManager(_ central: CBMCentralManager, didConnect peripheral: CBMPeripheral) {
        logger.info("Connected to \(peripheral.identifier.uuidString)")
        // Get the discovery matching the peripheral
        guard let discovery = discoveries.discovery(for: peripheral) else {
            logger.warning("Connect but could not find discovery for peripheral: \(peripheral.identifier.uuidString)")
            return
        }
        didConnect(to: discovery)
    }

    public func centralManager(
        _ central: CBMCentralManager,
        didFailToConnect peripheral: CBMPeripheral,
        error: Error?
    ) {
        logger.warning("Failed to connect to peripheral")
        retryAttempts += 1
        if retryAttempts < settings.retryAttempts {
            if let discovery = discoveries.discovery(for: peripheral) {
                Task {
                    logger.info("Retrying connection to peripheral")
                    try? await connect(to: discovery)
                }
            }
        } else {
            connectionContinuation?.resume(throwing: DeviceManagerError.failedToConnect)
            connectionContinuation = nil
        }
    }

    public func centralManager(
        _ central: CBMCentralManager,
        didDisconnectPeripheral peripheral: CBMPeripheral,
        error: Error?
    ) {
        didLoseConnection(to: peripheral)
    }
}
