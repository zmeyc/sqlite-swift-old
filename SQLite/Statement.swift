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
    let SQLITE_STATIC = unsafeBitCast(0, sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)
    
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
    
//    int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
//    int sqlite3_bind_blob64(sqlite3_stmt*, int, const void*, sqlite3_uint64,
//    void(*)(void*));

    public func bindDouble(value: Double, index: Int) throws {
        let result = sqlite3_bind_double(statement, Int32(index), value)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
    public func bindInt32(value: Int32, index: Int) throws {
        let result = sqlite3_bind_int(statement, Int32(index), value)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }

    public func bindInt64(value: Int64, index: Int) throws {
        let result = sqlite3_bind_int64(statement, Int32(index), value)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
    public func bindNil(index: Int) throws {
        let result = sqlite3_bind_null(statement, Int32(index))
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
    public func bindString(value: String, index: Int) throws {
        let result = sqlite3_bind_text(statement, Int32(index), value, -1, SQLITE_STATIC)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
//    int sqlite3_bind_text(sqlite3_stmt*,int,const char*,int,void(*)(void*));
//    int sqlite3_bind_text16(sqlite3_stmt*, int, const void*, int, void(*)(void*));
//    int sqlite3_bind_text64(sqlite3_stmt*, int, const char*, sqlite3_uint64,
//    void(*)(void*), unsigned char encoding);
//    int sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
//    int sqlite3_bind_zeroblob(sqlite3_stmt*, int, int n);
//    int sqlite3_bind_zeroblob64(sqlite3_stmt*, int, sqlite3_uint64);
    
    func step() throws -> Bool {
        let result = sqlite3_step(statement)
        switch result {
        case SQLITE_ROW: return true
        case SQLITE_DONE: return false
        default: break
        }
        throw Result.Code(result)
    }
    
    deinit {
        guard statement != nil else { return }
        db.statements.remove(statement)
        if SQLITE_OK != sqlite3_finalize(statement) {
            assertionFailure("Unable to finalize the statement")
        }
    }
}
