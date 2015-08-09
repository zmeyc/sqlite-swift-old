//
// Database.swift
//
// Copyright (c) 2015 Andrey Fidrya
//
// Licensed under the MIT license. For full copyright and license information,
// please see the LICENSE file.
//

import Foundation

public class Database {
    public typealias ExecCallback = (columnText: StringArray, columnNames: StringArray) -> Bool
    
    typealias sqlite3 = COpaquePointer
    
    var db: sqlite3 = nil
    var statements = Set<COpaquePointer>()
    
    public func open(filename: String) throws {
        let result = sqlite3_open(/* filename */ filename, /* ppDb */ &db)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
    }
    
    public func close() throws {
        guard statements.isEmpty else {
            throw Result.Error("Unable to close database: \(statements.count) prepared statement(s) still exist")
        }
        let result = sqlite3_close(db)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
        db = nil
    }

    public func execute(sql: String) throws {
        var errmsg: UnsafeMutablePointer<Int8> = nil
        let result = sqlite3_exec(db, sql, nil, nil, &errmsg)
        
        guard result == SQLITE_OK else {
            if let errorMessage = String.fromCStringRepairingIllFormedUTF8(errmsg).0 {
                throw Result.CodeAndErrorMessage(result, errorMessage)
            } else {
                throw Result.Code(result)
            }
        }
    }
    
    public func execute(sql: String, callback: ExecCallback) throws {
        var errmsg: UnsafeMutablePointer<Int8> = nil
        var c = callback
        let context = withUnsafePointer(&c) { ptr in
            return unsafeBitCast(ptr, UnsafeMutablePointer<Void>.self)
        }
        let result = sqlite3_exec(db, sql,
            { context, columnCount, columnText, columnNames in
                let callback = unsafeBitCast(context, UnsafePointer<ExecCallback>.self).memory
                let columnTextArray = StringArray(count: Int(columnCount), array: columnText)
                let columnNamesArray = StringArray(count: Int(columnCount), array: columnNames)
                let result = callback(columnText: columnTextArray, columnNames: columnNamesArray)
                return Int32(result ? 0 : 1)
            }, context, &errmsg)
        
        guard result == SQLITE_OK else {
            defer {
                sqlite3_free(errmsg)
            }
            if let errorMessage = String.fromCStringRepairingIllFormedUTF8(errmsg).0 {
                throw Result.CodeAndErrorMessage(result, errorMessage)
            } else {
                throw Result.Code(result)
            }
        }
    }
    
    public func prepare(sql: String) throws -> Statement {
        var statement: COpaquePointer = nil
        let result = sqlite3_prepare_v2(db, sql, -1, &statement, nil)
        guard result == SQLITE_OK else {
            throw Result.Code(result)
        }
        statements.insert(statement)
        return Statement(statement: statement, db: self)
    }
    
    deinit {
        if SQLITE_OK != sqlite3_close(db) {
            assertionFailure("Unable to close the database")
        }
    }
    
}