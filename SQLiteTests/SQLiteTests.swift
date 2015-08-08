//
// SQLiteTests.swift
//
// Copyright (c) 2015 Andrey Fidrya
//
// Licensed under the MIT license. For full copyright and license information,
// please see the LICENSE file.
//

import XCTest
@testable import SQLite

class SQLiteTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testExec() {
        let db = Database()
        do {
            try db.open(":memory:")
            try db.execute("create table table1(column1 varchar(10), column2 smallint)")
            try db.execute("insert into table1(column1, column2) values ('value1', 'value2')")
            try db.execute("select * from table1; select 123 as constValue") {
                columnText, columnNames in
                print("columnNames: \(columnNames)")
                print("columnText: \(columnText)")
                return true
            }
            let statement = try db.prepare("select * from table1")
            try statement.finalize()
            try db.close()
        } catch {
            XCTFail("\(error)")
        }
    }
}
