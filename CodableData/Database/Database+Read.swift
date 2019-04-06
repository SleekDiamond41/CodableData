//
//  Database+Read.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	static func read<T>(db: OpaquePointer, _ : T.Type, query: String, bindings: [Bindable]) -> [T] where T: Decodable & SQLModel {
		guard let table = Database._table(db: db, named: T.tableName) else {
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
	
	static func get<T: Decodable & SQLModel>(db: OpaquePointer, _: T.Type, limit: Int? = nil, page: Int = 1) -> [T] {
		var query = ""
		if let limit = limit {
			query += "LIMIT \(limit) OFFSET \((page-1) * limit)"
		}
		return read(db: db, T.self, query: query, bindings: [])
	}
	
	static func get<T: Decodable & SQLModel>(db: OpaquePointer, _: T.Type, filter: Filter<T>) -> [T] {
		return read(db: db, T.self, query: filter.query, bindings: filter.bindings)
	}
	
}

	
//MARK: - Sync
extension Database {
	
	public func get<U: Decodable & SQLModel>(_ : U.Type) -> [U] {
		return sync { db in
			return Database.get(db: db, U.self)
		}
	}
	
	public func get<U: Decodable & SQLModel>(_ : U.Type, limit: Int, page: Int = 1) -> [U] {
		return sync { db in
			return Database.get(db: db, U.self, limit: limit, page: page)
		}
	}
	
	public func get<U: Decodable & SQLModel>(with filter: Filter<U>) -> [U] {
		return sync { db in
			return Database.get(db: db, U.self, filter: filter)
		}
	}
	
	public func get<U: Decodable & SQLModel>(sorting: SortRule<U>) -> [U] {
		return sync { db in
			return Database.get(db: db, U.self, filter: Filter(sorting))
		}
	}
	
}

	
//MARK: - Async
extension Database {
	
	public func get<U: Decodable & SQLModel>(_ : U.Type, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(Database.get(db: db, U.self))
		}
	}
	
	public func get<U: Decodable & SQLModel>(_ : U.Type, limit: Int, page: Int = 1, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(Database.get(db: db, U.self, limit: limit, page: page))
		}
	}
	
	public func get<U: Decodable & SQLModel>(with filter: Filter<U>, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(Database.get(db: db, U.self, filter: filter))
		}
	}
	
	public func get<U: Decodable & SQLModel>(sorting: SortRule<U>, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(Database.get(db: db, U.self, filter: Filter(sorting)))
		}
	}
	
}
