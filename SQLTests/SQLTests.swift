//
//  SQLTests.swift
//  SQLTests
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import XCTest
@testable import SQL

struct Friend: Codable {
	let id: UUID
	let name: String
	let hair: String
	let person_id: UUID
}

extension Friend: DataModel {}


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
	
	func testCreateTable() {
		
		let table = Table(name: "person", columns: [
			Table.Column(name: "id", type: .integer, isPrimaryKey: true),
			Table.Column(name: "name", type: .text)
		])
		
		let e = XCTestExpectation(description: "com.expectation")
		
		db.create(table) {
			self.db.replace(Person(id: UUID(), name: "Michael")) {
				e.fulfill()
			}
		}
		wait(for: [e], timeout: 1.0)
	}
	
	func testGetRows() {
		
		let results = db.get(Person.self)
		XCTAssertEqual(results.count, 1)
		
//		if let first = results.first {
//			XCTAssertEqual(first.id, )
//			XCTAssertEqual(first.name, "Michael")
//
//			print(first)
//		}
		
//		let e = XCTestExpectation(description: "expected to get row")
//		e.expectedFulfillmentCount = 2
//
//		db.read(Person.self, where: "name LIKE 'Michael'", [(.or, "id IS 1")], limit: 10, page: 1) { people in
//			XCTAssertEqual(people, results)
//			e.fulfill()
//		}
//		db.read(Person.self, where: "name LIKE 'Michael'", [(.or, "id IS 1")], limit: 10) { people in
//			XCTAssertEqual(people, results)
//			e.fulfill()
//		}
//		db.read(Person.self, where: "name LIKE 'Michael'", [(.or, "id IS 1")]) { people in
//			XCTAssertEqual(people, results)
//			e.fulfill()
//		}
//
//		wait(for: [e], timeout: 1.0)
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
	
	func testReplace() {
		let id = UUID()
		
		let person = Person(id: id, name: "Billy Bob", nickName: "Billy")
		db.replace(person)
		
		let people = db.get(Person.self)
		
		XCTAssertEqual(people.count, 1)
		XCTAssertEqual(people.first, person)
	}
	
	func testEverything() {
		let pete = Friend(id: UUID(), name: "Joe Bob", hair: "Blue", person_id: UUID())
		db.replace(pete)
		
		let results = db.get(Friend.self)
		XCTAssertEqual(results.count, 1)
	}
	
	
	
	
	func testExample() {
		let game = Game(id: UUID(uuidString: "1994ABB7-F245-49C8-9DE4-C3F18D21F96F")!, name: "Onitama", playerCount: 2, difficulty: 6, startLevel: 4)
		
		db.replace(game)
		
		let results = db.get(Game.self)
		
		let filter = Game.filter(\.difficulty, is: .less(than: 8))
			.and(\.playerCount, is: .equal(to: 2))
		
		let onitama = db.get(where: filter)
		XCTAssertEqual(onitama.count, 1)
		print(onitama.first!)
		
		
		XCTAssertEqual(results.count, 1)
		XCTAssertEqual(results.first, game)
		
	}
	
}


struct Game: DataModel, Codable, Equatable, BetterFilterable {
	static func key<T>(for path: KeyPath<Game, T>) -> Game.CodingKeys where T : Bindable {
		switch path {
		case \Game.id: return .id
		case \Game.name: return .name
		case \Game.playerCount: return .playerCount
		case \Game.difficulty: return .difficulty
		case \Game.startLevel: return .startLevel
		default:
			fatalError("Unknown KeyPath")
		}
	}
	
	typealias FilterKey = CodingKeys
	
	let id: UUID
	let name: String
	let playerCount: Int
	let difficulty: Int
	let startLevel: Int
	
	enum CodingKeys: String, CodingKey {
		case id
		case name
		case playerCount = "player_count"
		case difficulty
		case startLevel = "start_level"
	}
}
