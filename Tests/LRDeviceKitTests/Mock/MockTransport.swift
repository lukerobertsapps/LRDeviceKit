//
//  MockTransport.swift
//
//
//  Created by Luke Roberts on 02/02/2024.
//

import Foundation
@testable import SwiftLockDeviceKit

class MockTransport: NSObject, Transport {

    var isReady: Bool = false

    var valueUpdated: AsyncStream<Data?> {
        AsyncStream { continuation in
            self.valueContinuation = continuation
        }
    }
    var valueContinuation: AsyncStream<Data?>.Continuation?

    var sentData: (Data, String)?
    func send(data: Data, using uuid: String) {
        sentData = (data, uuid)
    }
}
