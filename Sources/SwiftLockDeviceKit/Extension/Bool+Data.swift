//
//  Bool+Data.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

extension Bool {

    /// Returns a data representation of a boolean
    var data: UInt8 {
        self ? 0x01 : 0x00
    }
}

// Means a bool can be converted from data
extension Bool: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = value == 1
    }
}
