//
//  Numeric+Data.swift
//
//
//  Created by Luke Roberts on 27/01/2024.
//

import Foundation

// Note: cannot make generic extension on the 'Numeric' type
//
// This is because there is a warning as Self could be any object type
// therefore it is unsafe

extension UInt8 {

    /// Returns a data representation of the value
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {

    /// Returns a data representation of the value
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32 {

    /// Returns a data representation of the value
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<UInt32>.size)
    }
}

extension Int {

    /// Returns a data representation of the value
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Int>.size)
    }
}
