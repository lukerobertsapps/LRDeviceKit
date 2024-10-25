//
//  Transportable.swift
//  
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

/// A type that can be both packed and unpacked into and from data
typealias Transportable = Packable & Unpackable

/// Represents an object that can be packed into data
protocol Packable {

    /// Converts the object into a data representation
    /// - Returns: The raw data
    func pack() -> Data
}

/// Represents an object that can be created from data
protocol Unpackable {

    /// The payload for the object
    var payload: Data? { get }

    /// The initialiser in which the object gets created
    init?(from data: Data)
}
