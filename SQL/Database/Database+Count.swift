//
//  Database+Count.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation
import SQLite3


extension Database {
	
	private func _count<T>(db: OpaquePointer, _ : T.Type, query: String, bindings: [Bindable]) -> Int where T: Decodable {
		guard let table = Database._table(db: db, named: T.tableName) else {
			print("No such table")
			return 0
		}
		
		assert(!query.hasSuffix(";"))
		var q = ""
		if query.count > 0 {
			q += " " + query
		}
		
		var s = Statement("SELECT COUNT(*) FROM \(table.name)" + q + ";")
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
			
			let status = try s.step()
			
			guard status == .row else {
				print(String(reflecting: status))
				return 0
			}
			
			return try Int.unbind(from: s, at: 0)
			
		} catch {
			print(String(reflecting: error))
			return 0
		}
	}
	
	private func _count<T: Decodable>(db: OpaquePointer, _: T.Type, limit: Int? = nil, page: Int = 1) -> Int {
		var query = ""
		if let limit = limit {
			query += "LIMIT \(limit) OFFSET \((page-1) * limit)"
		}
		return _count(db: db, T.self, query: query, bindings: [])
	}
	
	private func _count<T: Decodable>(db: OpaquePointer, _: T.Type, filter: Filter<T>, limit: Int? = nil, page: Int = 1) -> Int {
		var query = filter.query
		if let limit = limit {
			query += " LIMIT \(limit) OFFSET \((page-1) * limit)"
		}
		return _count(db: db, T.self, query: query, bindings: filter.bindings)
	}
	
}


//MARK: - Sync
extension Database {
	
	public func count<T>(_ : T.Type) -> Int where T: Decodable {
		return sync { (db) -> Int in
			return _count(db: db, T.self)
		}
	}
	
	public func count<U: Decodable>(_ : U.Type, limit: Int, page: Int = 1) -> Int {
		return sync { db in
			return _count(db: db, U.self, limit: limit, page: page)
		}
	}
	
	public func count<U: Decodable>(where filter: Filter<U>) -> Int {
		return sync { db in
			return _count(db: db, U.self, filter: filter)
		}
	}
	
	public func count<U: Decodable>(where filter: Filter<U>, limit: Int, page: Int = 1) -> Int {
		return sync { db in
			return _count(db: db, U.self, filter: filter, limit: limit, page: page)
		}
	}
	
}


//MARK: - Async
extension Database {
	
	public func count<U: Decodable>(_ : U.Type, _ handler: @escaping (Int) -> Void) {
		async { (db) in
			handler(self._count(db: db, U.self))
		}
	}
	
	public func count<U: Decodable>(_ : U.Type, limit: Int, page: Int = 1, _ handler: @escaping (Int) -> Void) {
		async { (db) in
			handler(self._count(db: db, U.self, limit: limit, page: page))
		}
	}
	
	public func count<U: Decodable>(where filter: Filter<U>, _ handler: @escaping (Int) -> Void) {
		async { (db) in
			handler(self._count(db: db, U.self, filter: filter))
		}
	}
	
	public func count<U: Decodable>(where filter: Filter<U>, limit: Int, page: Int = 1, _ handler: @escaping (Int) -> Void) {
		async { (db) in
			handler(self._count(db: db, U.self, filter: filter, limit: limit, page: page))
		}
	}
	
}
