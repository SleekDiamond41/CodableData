//
//  RowReadable.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import SQLite3


public struct Person: SQLModel, Equatable {
	public let id: UUID
	public let name: String
	public let nickName: String?
	
	public init(id: UUID, name: String, nickName: String? = nil) {
		self.id = id
		self.name = name
		self.nickName = nickName
	}
	
	public enum CodingKeys: String, CodingKey {
		case id
		case name
		case nickName = "nick_name"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.id = try container.decode(UUID.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.nickName = try container.decode(String?.self, forKey: .nickName)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encode(nickName, forKey: .nickName)
	}
}


enum ReaderError: Error {
	case noSuchTable(String)
}

class Reader {
	
	private func read<T: Decodable>(_ : T.Type, from s: Statement, in table: Table) throws -> T {
		let reader = _Reader(s, table)
		return try T.init(from: reader)
	}
	
	func read<T: Decodable>(_ : T.Type, s: Statement, _ table: Table) throws -> T {
		let r = _Reader(s, table)
		return try T.init(from: r)
	}
}

class _Reader: Decoder {
	var codingPath: [CodingKey] {
		return []
	}
	
	var userInfo: [CodingUserInfoKey : Any] {
		return [:]
	}
	
	let s: Statement
	let table: Table
	
	init(_ s: Statement, _ table: Table) {
		self.s = s
		self.table = table
	}
	
	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		return KeyedDecodingContainer(KeyedContainer(s, table))
	}
	
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError()
	}
	
	func singleValueContainer() throws -> SingleValueDecodingContainer {
		fatalError()
	}
	
	
	class KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
		var codingPath: [CodingKey] {
			return []
		}
		
		var allKeys: [Key] {
			return []
		}
		
		let s: Statement
		let table: Table
		
		lazy var jsonDecoder = JSONDecoder()
		
		init(_ s: Statement, _ table: Table) {
			self.s = s
			self.table = table
		}
		
		func contains(_ key: Key) -> Bool {
			return index(for: key) != nil
		}
		
		func index(for key: Key) -> Int32? {
			guard let index = table.columns.firstIndex(where: { $0.name == key.stringValue }) else {
				fatalError()
//				return nil
			}
			return Int32(index)
		}
		
		func decodeNil(forKey key: Key) throws -> Bool {
			guard index(for: key) != nil else {
				return true
			}
//			ColumnType(String(cString: sqlite3_column_decltype(s.p, i)))
			return false
		}
		
		func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
			guard let i = index(for: key) else {
				fatalError()
			}
			
			if let U = T.self as? Unbindable.Type {
				return try U.unbind(from: s, at: i) as! T
			} else {
				print(T.self)
				let data = try Data.unbind(from: s, at: i)
				return try jsonDecoder.decode(T.self, from: data)
			}
		}
		
		func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
			fatalError()
		}
		
		func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
			fatalError()
		}
		
		func superDecoder() throws -> Decoder {
			fatalError()
		}
		
		func superDecoder(forKey key: Key) throws -> Decoder {
			fatalError()
		}
		
	}
	
}
