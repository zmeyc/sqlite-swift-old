//
// StringArray.swift
//
// Copyright (c) 2015 Andrey Fidrya
//
// Licensed under the MIT license. For full copyright and license information,
// please see the LICENSE file.
//

import Foundation

public class StringArray {
    public let count: Int

    typealias CString = UnsafeMutablePointer<Int8>
    typealias CStringArray = UnsafeMutablePointer<CString>
    
    let array: CStringArray
    
    init(count: Int, array: CStringArray) {
        self.count = count
        self.array = array
    }
    
    subscript(index: Int) -> String {
        guard case 0..<count = index else { return String() }
        return String.fromCStringRepairingIllFormedUTF8(array[index]).0 ?? String()
    }
    
    public func toArray() -> [String] {
        var result = [String]()
        result.reserveCapacity(count)
        for var i = 0; i < count; ++i {
            let string = String.fromCStringRepairingIllFormedUTF8(array[i]).0 ?? String()
            result.append(string)
        }
        return result
    }
}

extension StringArray: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(toArray())"
    }
}
