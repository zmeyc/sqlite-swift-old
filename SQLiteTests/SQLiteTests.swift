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
            try db.exec("create table tbl1(one varchar(10), two smallint)")
            try db.exec("insert into tbl1(one, two) values ('a', 'b')")
            try db.exec("select * from tbl1") {
                columnText, columnNames in
                return true
            }
            try db.close()
        } catch {
            XCTFail("\(error)")
        }
    }
}
