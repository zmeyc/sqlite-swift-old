//
// Statement.swift
//
// Copyright (c) 2015 Andrey Fidrya
//
// Licensed under the MIT license. For full copyright and license information,
// please see the LICENSE file.
//

import Foundation

public class Statement {
    let db: Database
    var statement: COpaquePointer
    
    init(statement: COpaquePointer, db: Database) {
        assert(statement != nil, "Attempt to create a nil statement")
        self.statement = statement
        self.db = db
    }
    
    public func finalize() throws {
        guard statement != nil else {
            throw Result.Error("Attempt to finalize a nil statement")
        }
        db.statements.remove(statement)
        let result = sqlite3_finalize(statement)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
        statement = nil
    }
    
    deinit {
        guard statement != nil else { return }
        db.statements.remove(statement)
        if SQLITE_OK != sqlite3_finalize(statement) {
            assertionFailure("Unable to finalize the statement")
        }
    }
}
