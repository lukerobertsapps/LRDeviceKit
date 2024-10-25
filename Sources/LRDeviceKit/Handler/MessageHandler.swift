//
//  MessageHandler.swift
//
//
//  Created by Luke Roberts on 02/02/2024.
//

import Foundation

/// Responsible for handling Messages between features and the transport
class MessageHandler: Handler {

    var replies: [MessageCommand: CheckedContinuation<Transportable, Error>] = [:]
    var valueUpdateTask: Task<Void, Never>?

    var listenerStream: AsyncStream<Message>?
    var listenerContinuation: AsyncStream<Message>.Continuation?
    var listenerMessageCommand: MessageCommand?

    let requestCharacteristic: CBUUID = .requestUUID
    let replyCharacteristic: CBUUID = .replyUUID
    let timeout: TimeInterval
    let transport: Transport

    required init(transport: Transport, timeout: TimeInterval = 10) {
        self.transport = transport
        self.timeout = timeout
        listenForTransportUpdates()
    }

    @discardableResult
    func send(_ data: Transportable) async throws -> Transportable {
        // Check transportable data is a message
        guard let message = data as? Message else {
            logger.warning("Attempted to send invalid transportable data")
            throw MessageHandlerError.invalidTransportableData
        }
        // Send data over the transport
        let packedData = message.pack()
        transport.send(data: packedData, using: requestCharacteristic.uuidString)
        // Use a continuation so method can be called asynchronously
        return try await withCheckedThrowingContinuation { continuation in
            // Store continuation so can be called when value is updated
            replies[message.command] = continuation
            // Start a timeout for any errors
            startTimeout(for: message.command)
        }
    }

    func listenForUpdates(to command: MessageCommand) -> AsyncStream<Message> {
        let stream = AsyncStream { continuation in
            self.listenerContinuation = continuation
        }
        listenerStream = stream
        listenerMessageCommand = command
        return stream
    }

    func stopListening(to command: MessageCommand) {
        listenerStream = nil
        listenerContinuation?.finish()
        listenerMessageCommand = nil
    }

    private func valueUpdated(_ data: Data?) {
        // Check valid data was sent back
        guard let data = data, let message = Message(from: data) else {
            logger.warning("Could not unpack message. Optional data: \(data?.stringRepresentation ?? "nil")")
            return
        }
        // If a message, resume the continuation
        if let continuation = replies[message.command] {
            // If the message is not a reply then throw an error
            if message.type != .reply {
                logger.warning("Received message but it's not a reply")
                continuation.resume(throwing: MessageHandlerError.invalidMessageType)
            }
            // Resume continuation and remove reference to message
            continuation.resume(returning: message)
            replies.removeValue(forKey: message.command)
        }
        // Handle notification messages
        if message.type == .notification && message.command == listenerMessageCommand {
            listenerContinuation?.yield(message)
        }
    }

    private func listenForTransportUpdates() {
        // Setup a task to listen to the async stream on the transport
        valueUpdateTask = Task {
            // For each value received call the valueUpdated method
            for await data in transport.valueUpdated {
                valueUpdated(data)
            }
        }
    }

    private func startTimeout(for message: MessageCommand) {
        // Start a timeout, throw an error if no reply has been received in time
        Task {
            // Sleep for the timeout duration
            try await Task.sleep(for: .seconds(timeout))
            // If a value exists for the message id, remove it and throw timeout error
            if let timeout = replies.removeValue(forKey: message) {
                logger.warning("Handler timed out")
                timeout.resume(throwing: MessageHandlerError.timeout)
            }
        }
    }
}
