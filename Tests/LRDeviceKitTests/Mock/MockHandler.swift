//
//  MockHandler.swift
//  
//
//  Created by Luke Roberts on 03/02/2024.
//

@testable import SwiftLockDeviceKit

class MockHandler: Handler {

    var transport: Transport = MockTransport()

    var dataSent: Transportable?
    var errorToThrow: MessageHandlerError?
    var dataToReturn: Transportable?
    func send(_ data: Transportable) async throws -> Transportable {
        if let errorToThrow {
            throw errorToThrow
        } else {
            self.dataSent = data
            if let dataToReturn {
                return dataToReturn
            } else {
                return data
            }
        }
    }
}
