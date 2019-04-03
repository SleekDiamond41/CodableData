//
//  Writer.swift
//  SQL
//
//  Created by Michael Arrington on 4/2/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation

extension Table.Column {
	init(name: String, type: Value) {
		switch type {
		case .text:
			self.type = .text
		case .integer:
			self.type = .integer
		case .double:
			self.type = .double
		case .blob:
			self.type = .blob
		case .null:
			self.type = .integer
		}
		self.name = name
		self.isPrimaryKey = name == "id"
	}
}

class Writer<T: Encodable> {
	
	private let writer = _Writer()
	
	
	func prepare(_ value: T) throws {
		try value.encode(to: writer)
	}
	
	func tableDefinition() -> Table {
		return Table(name: T.tableName, columns:
			writer.container!.values.map {
				Table.Column(name: $0.0, type: $0.1.bindingValue)
			}
		)
	}
	
	func replace<T>(_ value: T, into table: inout Table, db: OpaquePointer, newColumnsHandler: ([Table.Column]) -> Void) throws where T: Encodable {
		
		guard let container = writer.container else {
			fatalError()
		}
		
		newColumnsHandler(container.values.filter { (val) in
			return !table.columns.contains(where: { $0.name == val.0 })
			}.map {
				Table.Column(name: $0.0, type: $0.1.bindingValue)
			})
		
		let keys = container.values.map { $0.0 }.joined(separator: ", ")
		let values = [String](repeating: "?", count: container.values.count).joined(separator: ", ")
		
		var s = Statement("REPLACE INTO \(table.name) (\(keys)) VALUES (\(values))")
		
		try s.prepare(in: db)
		defer {
			s.finalize()
		}
		var i: Int32 = 1
		for (_ , value) in container.values {
			try value.bindingValue.bind(into: s, at: i)
			i += 1
		}
		
		try s.step()
		
		//TODO: return the inserted row
	}
	
}

fileprivate protocol _WriterContainer {
	var values: [(String, Bindable)] { get }
}

class _Writer: Encoder {
	var codingPath: [CodingKey] {
		return []
	}
	
	var userInfo: [CodingUserInfoKey : Any] {
		return [:]
	}
	
	fileprivate var container: _WriterContainer?
	
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		let c = KeyedContainer<Key>()
		self.container = c
		return KeyedEncodingContainer(c)
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		fatalError()
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		fatalError()
	}
	
	class KeyedContainer<Key>: KeyedEncodingContainerProtocol, _WriterContainer where Key: CodingKey {
		
		
		var codingPath: [CodingKey] {
			return []
		}
		
		private(set) var values = [(String, Bindable)]()
		private var indices = [String: Int32]()
		
		private let jsonEncoder = JSONEncoder()
		
		
//		private func index(for key: Key) -> Int32 {
//			if let i = indices[key.stringValue] {
//				return i
//			}
//
//			let str = key.stringValue
//
//			guard let index = table.columns.firstIndex(where: { $0.name == str }) else {
//				fatalError("No column named '\(str)'")
//				//				return nil
//			}
//
//			let i = Int32(index)
//			indices[str] = i
//			return i
//		}
		
		func encodeNil(forKey key: Key) throws {
			
//			switch table.columns[Int(i)].type {
//			case .text:
//				let val: String? = nil
//				values.append((key.stringValue, val))
//			case .integer:
//				let val: Int64? = nil
//				values.append((key.stringValue, val))
//			case .double:
//				let val: Double? = nil
//				values.append((key.stringValue, val))
//			case .blob:
//				let val: Data? = nil
//				values.append((key.stringValue, val))
//			}
		}
		
		
		func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
//			let i = index(for: key)
			
			if let bindable = value as? Bindable {
				values.append((key.stringValue, bindable))
			} else {
				let data = try jsonEncoder.encode(value)
				values.append((key.stringValue, data))
			}
		}
		
		func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
			fatalError()
		}
		
		func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
			fatalError()
		}
		
		func superEncoder() -> Encoder {
			fatalError()
		}
		
		func superEncoder(forKey key: Key) -> Encoder {
			fatalError()
		}
		
	}
	
}
