//
//  Feature.swift
//  
//
//  Created by Luke Roberts on 02/02/2024.
//

import Foundation

/// Features allow a device to perform an action
///
/// Features send data through a handler
/// This class is a feature base class and is designed to be inherited from
open class Feature {

    /// The handler used to access the transport
    public let handler: Handler

    /// Initialises the feature with a handler
    /// - Parameter handler: The handler used to access the transport
    required public init(handler: Handler) {
        self.handler = handler
    }
}
