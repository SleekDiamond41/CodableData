//
//  RowReadable.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import SQLite3


extension Decodable {
	static var tableName: String { return "\(Self.self)" }
}

extension Encodable {
	static var tableName: String { return "\(Self.self)" }
}

public struct Person: Decodable, Equatable {
	public let id: Int
	public let name: String
	
	public enum CodingKeys: String, CodingKey {
		case id
		case name
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
			guard let i = index(for: key) else {
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
