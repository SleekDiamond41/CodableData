//
//  SQLTests.swift
//  SQLTests
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import XCTest
@testable import SQL

class SQLTests: XCTestCase {
	
	var dir: URL {
		let dirs = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		let appSupport = dirs.first!
		return appSupport.appendingPathComponent("SQL")
	}
	
	lazy var db = Database(dir: dir, name: "Testing")
	
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testExample() {
		
		let table = Table(name: "person", columns: [
			Table.Column(name: "id", type: .integer),
			Table.Column(name: "name", type: .text)
		])
		
		let e = XCTestExpectation(description: "com.expectation")
		
		db.create(table) {
			self.db.replace(into: table.name, [("id", 1), ("name", "Michael")]) {
				e.fulfill()
			}
		}
		wait(for: [e], timeout: 1.0)
	}
	
	func testGetRows() {
		
		let results = db.read(Person.self)
		XCTAssertEqual(results.count, 1)
		
		if let first = results.first {
			XCTAssertEqual(first.id, 1)
			XCTAssertEqual(first.name, "Michael")
			
			print(first)
		}
		
		let e = XCTestExpectation(description: "expected to get row")
		e.expectedFulfillmentCount = 2
		
		db.read(Person.self, where: "name LIKE 'Michael'", [(.or, "id IS 1")], limit: 10, page: 1) { people in
			XCTAssertEqual(people, results)
			e.fulfill()
		}
		db.read(Person.self, where: "name LIKE 'Michael'", [(.or, "id IS 1")], limit: 10) { people in
			XCTAssertEqual(people, results)
			e.fulfill()
		}
		db.read(Person.self, where: "name LIKE 'Michael'", [(.or, "id IS 1")]) { people in
			XCTAssertEqual(people, results)
			e.fulfill()
		}
		
		wait(for: [e], timeout: 1.0)
	}
	
	func testGetTable() {
		guard let table = db.table("person") else {
			XCTFail("Table not found")
			return
		}
		
		XCTAssertEqual(table.name, "person")
		
		XCTAssertEqual(table.columns[0].name, "id")
		XCTAssertEqual(table.columns[0].type, .integer)
		XCTAssertTrue (table.columns[0].isPrimaryKey)
		
		XCTAssertEqual(table.columns[1].name, "name")
		XCTAssertEqual(table.columns[1].type, .text)
		XCTAssertFalse(table.columns[1].isPrimaryKey)
		
		let e = XCTestExpectation(description: "com.random")
		
		db.table("person") { (table) in
			defer { e.fulfill() }
			
			guard let table = table else {
				XCTFail("Table not found")
				return
			}
			
			XCTAssertEqual(table.name, "person")
			
			XCTAssertEqual(table.columns[0].name, "id")
			XCTAssertEqual(table.columns[0].type, .integer)
			XCTAssertTrue (table.columns[0].isPrimaryKey)
			
			XCTAssertEqual(table.columns[1].name, "name")
			XCTAssertEqual(table.columns[1].type, .text)
			XCTAssertFalse(table.columns[1].isPrimaryKey)
		}
		
		wait(for: [e], timeout: 1.0)
	}
	
	func testGetNone() {
//		XCTAssertEqual(db.read(Person.self).count, 1)
//		XCTAssertEqual(db.read(Person.self, where: "id IS NOT 1").count, 0)
//
//		let e = XCTestExpectation(description: "com.testGetNone")
//		e.expectedFulfillmentCount = 2
//
//		db.read(Person.self) { people in
//			XCTAssertEqual(people.count, 1)
//			e.fulfill()
//		}
//		db.read(Person.self, where: "id IS NOT 1") { people in
//			XCTAssertEqual(people.count, 0)
//			e.fulfill()
//		}
//
//		wait(for: [e], timeout: 1.0)
	}
	
}
