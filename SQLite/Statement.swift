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
        
    public var columnCount: Int { return Int(sqlite3_column_count(statement)) }
    public var dataCount: Int { return Int(sqlite3_data_count(statement)) }
    
    let db: Database
    var statement: COpaquePointer
    
    init(statement: COpaquePointer, db: Database) {
        assert(statement != nil, "Attempt to create a nil statement")
        self.statement = statement
        self.db = db
    }
    
    public func step() throws -> Bool {
        let result = sqlite3_step(statement)
        switch result {
        case SQLITE_ROW: return true
        case SQLITE_DONE: return false
        default: break
        }
        throw Result.Code(result)
    }
    
    public func reset() throws {
        let result = sqlite3_reset(statement)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
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

    public func bindDouble(value: Double, column: Int) throws {
        let result = sqlite3_bind_double(statement, Int32(column), value)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
    public func bindInt32(value: Int32, column: Int) throws {
        let result = sqlite3_bind_int(statement, Int32(column), value)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }

    public func bindInt64(value: Int64, column: Int) throws {
        let result = sqlite3_bind_int64(statement, Int32(column), value)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
    public func bindNil(column: Int) throws {
        let result = sqlite3_bind_null(statement, Int32(column))
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
    public func bindString(value: String, column: Int) throws {
        let result = sqlite3_bind_text(statement, Int32(column), value, -1, SQLITE_STATIC)
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
    
    
//    const void *sqlite3_column_blob(sqlite3_stmt*, int iCol);
//    int sqlite3_column_bytes(sqlite3_stmt*, int iCol);
//    int sqlite3_column_bytes16(sqlite3_stmt*, int iCol);
//    double sqlite3_column_double(sqlite3_stmt*, int iCol);
    
    func int32(column: Int) -> Int32? {
        let i = Int32(column)
        guard sqlite3_column_type(statement, i) != SQLITE_NULL else {
            return nil
        }
        return sqlite3_column_int(statement, i)
    }
    
    func int32Value(column: Int) -> Int32 {
        return sqlite3_column_int(statement, Int32(column))
    }
    
    func int32Value(column: Int, defaultValue: Int32) -> Int32? {
        let i = Int32(column)
        guard sqlite3_column_type(statement, i) != SQLITE_NULL else {
            return defaultValue
        }
        return sqlite3_column_int(statement, i)
    }

    func int64(column: Int) -> Int64? {
        let i = Int32(column)
        guard sqlite3_column_type(statement, i) != SQLITE_NULL else {
            return nil
        }
        return sqlite3_column_int64(statement, i)
    }

    func int64Value(column: Int) -> Int64 {
        return sqlite3_column_int64(statement, Int32(column))
    }

    func int64Value(column: Int, defaultValue: Int64) -> Int64 {
        let i = Int32(column)
        guard sqlite3_column_type(statement, i) != SQLITE_NULL else {
            return defaultValue
        }
        return sqlite3_column_int64(statement, i)
    }

    func string(column: Int) -> String? {
        let text = sqlite3_column_text(statement, Int32(column))
        guard text != nil else { return nil }
        let ptr = unsafeBitCast(text, UnsafePointer<Int8>.self)
        return String.fromCStringRepairingIllFormedUTF8(ptr).0
    }
    
    func stringValue(column: Int) -> String {
        return string(column) ?? ""
    }
    
    func columnType(column: Int) throws -> ColumnType {
        let rawColumnType = sqlite3_column_type(statement, Int32(column))
        guard let type = ColumnType(rawValue: Int(rawColumnType)) else {
            throw Result.Error("Invalid column type: \(rawColumnType)")
        }
        return type
    }
    
    deinit {
        guard statement != nil else { return }
        db.statements.remove(statement)
        if SQLITE_OK != sqlite3_finalize(statement) {
            assertionFailure("Unable to finalize the statement")
        }
    }
}
