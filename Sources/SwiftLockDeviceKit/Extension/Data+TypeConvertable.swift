//
//  Data+TypeConvertable.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

extension Data {

    /// Converts data to any type conforming to ExpressibleByIntegerLiteral
    /// - Returns: The type
    func typeConverted<T: ExpressibleByIntegerLiteral>() -> T? {
        var value: T = 0
        // Get the memory size of the type
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        // Convert using the unsafe bytes API
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0) })
        return value
    }
}
