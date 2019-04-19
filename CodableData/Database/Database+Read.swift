//
//  Database+Read.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension CDDatabase {
	
	static func read<T>(db: OpaquePointer, _ : T.Type, query: String, bindings: [CDBindable]) -> [T] where T: Decodable & CDModel {
		guard let table = CDDatabase._table(db: db, named: T.tableName) else {
			print("No such table")
			return []
		}
		
		let q: String
		if query.count > 0 {
			q = " " + query
		} else {
			q = ""
		}
		
		var s = Statement("SELECT * FROM \(table.name)" + q + ";")
		do {
			try s.prepare(in: db)
			defer {
				s.finalize()
			}
			
			var i: Int32 = 1
			for b in bindings {
				try b.bindingValue.bind(into: s, at: i)
				i += 1
			}
			
			var results = [T]()
			var status = try s.step()
			
			let reader = Reader()
			
			while status == .row {
				results.append(try reader.read(T.self, s: s, table))
				status = try s.step()
			}
			return results
			
		} catch {
			print(String(reflecting: error))
			return []
		}
	}
	
	static func get<T: Decodable & CDModel>(db: OpaquePointer, _: T.Type, limit: Int? = nil, page: Int = 1) -> [T] {
		var query = ""
		if let limit = limit {
			query += "LIMIT \(limit) OFFSET \((page-1) * limit)"
		}
		return read(db: db, T.self, query: query, bindings: [])
	}
	
	static func get<T: Decodable & CDModel>(db: OpaquePointer, _: T.Type, filter: CDFilter<T>) -> [T] {
		return read(db: db, T.self, query: filter.query, bindings: filter.bindings)
	}
	
}

	
//MARK: - Sync
extension CDDatabase {
	
	public func get<U, V>(_ : U.Type, id: V) -> U? where U: Decodable & CDModel & CDFilterable, U.PrimaryKey == V {
		let filter = CDFilter(\U.id, is: .equal(to: id)).limit(1)
		return get(with: filter).first
	}
	
	public func get<U: Decodable & CDModel>(_ : U.Type) -> [U] {
		return sync { db in
			return CDDatabase.get(db: db, U.self)
		}
	}
	
	public func get<U: Decodable & CDModel>(_ : U.Type, limit: Int, page: Int = 1) -> [U] {
		return sync { db in
			return CDDatabase.get(db: db, U.self, limit: limit, page: page)
		}
	}
	
	public func get<U: Decodable & CDModel>(with filter: CDFilter<U>) -> [U] {
		return sync { db in
			return CDDatabase.get(db: db, U.self, filter: filter)
		}
	}
	
	public func get<U: Decodable & CDModel>(sorting: CDSortRule<U>) -> [U] {
		return sync { db in
			return CDDatabase.get(db: db, U.self, filter: CDFilter(sorting))
		}
	}
	
}

	
//MARK: - Async
extension CDDatabase {
	
	public func get<U, V>(_ : U.Type, id: V, _ handler: @escaping (U?) -> Void) where U: Decodable & CDModel & CDFilterable, U.PrimaryKey == V {
		let filter = CDFilter(\U.id, is: .equal(to: id)).limit(1)
		get(with: filter) {
			handler($0.first)
		}
	}
	
	public func get<U: Decodable & CDModel>(_ : U.Type, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(CDDatabase.get(db: db, U.self))
		}
	}
	
	public func get<U: Decodable & CDModel>(_ : U.Type, limit: Int, page: Int = 1, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(CDDatabase.get(db: db, U.self, limit: limit, page: page))
		}
	}
	
	public func get<U: Decodable & CDModel>(with filter: CDFilter<U>, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(CDDatabase.get(db: db, U.self, filter: filter))
		}
	}
	
	public func get<U: Decodable & CDModel>(sorting: CDSortRule<U>, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(CDDatabase.get(db: db, U.self, filter: CDFilter(sorting)))
		}
	}
	
}
