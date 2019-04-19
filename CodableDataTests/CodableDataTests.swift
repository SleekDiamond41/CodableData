//
//  SQLTests.swift
//  SQLTests
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import XCTest
@testable import CodableData

struct Friend: Codable, CDUUIDModel {
	let id: UUID
	let name: String
	let hair: String
	let personID: UUID
	
	enum CodingKeys: String, CodingKey {
		case id
		case name
		case hair
		case personID = "person_id"
	}
	
	typealias FilterKey = CodingKeys
	
	static func key<T>(for path: KeyPath<Friend, T>) -> Friend.CodingKeys where T : CDBindable {
		switch path {
		case \Friend.id: return .id
		case \Friend.name: return .name
		case \Friend.hair: return .hair
		case \Friend.personID: return .personID
		default:
			fatalError("Unknown key")
		}
	}
}

extension Person {
	struct Name: CDUUIDModel {
		static var tableName: String {
			return "[Person].Name"
		}
		
		let id: UUID
		
		struct Pronoun: CDUUIDModel {
			let id: UUID
		}
	}
}


class SQLTests: XCTestCase {
	
	private(set) lazy var db = CDDatabase(CDDatabase.Configuration(filename: "Testing"))
	
	func testFormatString() {		
		let a = Table(name: "Person", columns: [])
		XCTAssertEqual(a.name, "\"Person\"")
		
		let b = Table(name: "PersonName", columns: [])
		XCTAssertEqual(b.name, "\"PersonName\"")
		
		let c = Table(name: "Person.Name", columns: [])
		XCTAssertEqual(c.name, "\"Person.Name\"")
		
		let d = Table(name: "[Person].Name", columns: [Table.Column(name: "id", type: .text)])
		XCTAssertEqual(d.name, "\"[Person].Name\"")
		
		db.create(d)
		
	}
	
}


struct Game: CDUUIDModel, Equatable {
	static func key<T>(for path: KeyPath<Game, T>) -> FilterKey where T : CDBindable {
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
