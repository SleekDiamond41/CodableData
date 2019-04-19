//
//  TableTests.swift
//  SQLTests
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import XCTest
@testable import CodableData

class TableTests: SQLTests {
	
	private let table = TableTest.table
	
	override func setUp() {
		super.setUp()
		
//		drop()
	}
	
	override func tearDown() {
		super.tearDown()
		
		drop()
	}
	
	func drop() {
		db.drop(table)
	}
	
	func testCreateNormal() {
		
		db.create(table)
		
		drop()

		let e = XCTestExpectation(description: "com.SQL.\(#function)")
		db.create(table) {
			e.fulfill()
		}
		wait(for: [e], timeout: 0.1)
	}
	
	func testCreateAlreadyExists() {
		db.create(table)
		db.create(table)
		
		drop()
		
		let e = XCTestExpectation(description: "com.SQL.\(#function)")
		db.create(table) {
			self.db.create(self.table) {
				e.fulfill()
			}
		}
		wait(for: [e], timeout: 0.1)
	}
	
	func testDropExisting() {
		db.create(table)
		db.drop(table)
		
		let e = XCTestExpectation(description: "com.SQL.\(#function)")
		db.create(table) {
			self.db.drop(self.table) {
				e.fulfill()
			}
		}
		wait(for: [e], timeout: 0.1)
	}
	
	func testDropNone() {
		db.drop(table)
		
		let e = XCTestExpectation(description: "com.SQL.\(#function)")
		db.drop(table) {
			e.fulfill()
		}
		wait(for: [e], timeout: 0.1)
	}
	
}


fileprivate struct TableTest: CDModel {
	static let table: Table = {
		return Table(name: "\(TableTest.self)".lowercased(), columns: [
			Table.Column(name: "id", type: .text),
			Table.Column(name: "name", type: .text),
			Table.Column(name: "count", type: .integer),
			Table.Column(name: "score", type: .double),
			Table.Column(name: "is_happy", type: .integer),
			Table.Column(name: "json", type: .blob),
		])
	}()
	
	let id: UUID
	let name: String
	let count: Int
	let score: Double
	let isHappy: Bool
	let json: Data = {
		return """
{"height":{"feet":6,"inches":1}}
""".data(using: .utf8)!
	}()
	
	enum CodingKeys: String, CodingKey {
		case id
		case name
		case count
		case score
		case isHappy = "is_happy"
		case json
	}
	
	typealias FilterKey = CodingKeys
	
	static func key<T>(for path: KeyPath<TableTest, T>) -> TableTest.CodingKeys where T : CDBindable {
		switch path {
//		case \TableTest.id:
//			return .id
//		case \TableTest.name:
//			return .name
//		case \TableTest.count:
//			return .count
//		case \TableTest.isHappy:
//			return .isHappy
		default:
			fatalError("Unknown KeyPath")
		}
	}
}
