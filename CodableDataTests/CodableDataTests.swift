//
//  SQLTests.swift
//  SQLTests
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import XCTest
@testable import CodableData

struct Friend: SQLModel {
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
	
	static func key<T>(for path: KeyPath<Friend, T>) -> Friend.CodingKeys where T : Bindable {
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
	struct Name: UUIDModel {
		let id: UUID
		
		struct Pronoun: UUIDModel {
			let id: UUID
		}
	}
}


class SQLTests: XCTestCase {
	
	var dir: URL {
		let dirs = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		let appSupport = dirs.first!
		return appSupport.appendingPathComponent("SQL")
	}
	
	private(set) lazy var db = Database(Database.Configuration(filename: "Testing"))
	
	func testFormatString() {
		print(Person.tableName)
		print(Person.Name.tableName)
		print(Person.Name.Pronoun.tableName)
		
		let a = "Person"
		let b = a.sqlFormatted()
		XCTAssertEqual(b, "[Person]")
		
		let c = "PersonName"
		let d = c.sqlFormatted()
		XCTAssertEqual(d, "[PersonName]")
		
		let e = "Person.Name"
		let f = e.sqlFormatted()
		XCTAssertEqual(f, "[Person.Name]")
	}
	
}


struct Game: SQLModel, Equatable {
	static func key<T>(for path: KeyPath<Game, T>) -> FilterKey where T : Bindable {
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
