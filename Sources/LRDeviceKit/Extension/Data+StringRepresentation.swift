//
//  Data+StringRepresentation.swift
//
//
//  Created by Luke Roberts on 26/01/2024.
//

import Foundation

extension Data {

    /// A hex string representation of the data
    var stringRepresentation: String {
        self.map { String(format: "%02x", $0) }.joined()
    }
}
