//
// Result.swift
//
// Copyright (c) 2015 Andrey Fidrya
//
// Licensed under the MIT license. For full copyright and license information,
// please see the LICENSE file.
//

import Foundation

public enum Result: ErrorType {
    case Code(Int32)
    case CodeAndErrorMessage(Int32, String?)
    case Error(String)
    
    public var errorString: String {
        switch self {
        case let Code(result):
            if let errorMessage = String.fromCStringRepairingIllFormedUTF8(
                sqlite3_errstr(result)).0 {
                    return errorMessage
            }
        case let CodeAndErrorMessage(_, errorMessage):
            guard let errorMessage = errorMessage else { break }
            return errorMessage
        case let Error(errorMessage):
            return errorMessage
        }
        return String()
    }
}
