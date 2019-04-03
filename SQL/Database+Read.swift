//
//  Database+Read.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	private func _read<T: Decodable & Loadable>(db: OpaquePointer, _: T.Type, limit: Int? = nil, page: Int = 1) -> [T] {
		guard let table = Database._table(db: db, named: T.tableName) else {
			print("No such table")
			return []
		}
		
		var query = "SELECT * FROM \(T.tableName)"
		if let limit = limit {
			query += " LIMIT \(limit) OFFSET \((page-1) * limit)"
		}
		query += ";"
		
		var s = Statement(query)
		do {
			try s.prepare(in: db)
			defer {
				s.finalize()
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
	
	private func _read<T: Decodable & Loadable>(db: OpaquePointer, _: T.Type, filter: Filter<T>, limit: Int? = nil, page: Int = 1) -> [T] {
		guard let table = Database._table(db: db, named: T.tableName) else {
			print("No such table")
			return []
		}
		
		var query = "SELECT * FROM \(T.tableName)"
		query += " " + filter.query
		if let limit = limit {
			query += " LIMIT \(limit) OFFSET \((page-1) * limit)"
		}
		query += ";"
		
		var s = Statement(query)
		do {
			try s.prepare(in: db)
			defer {
				s.finalize()
			}
			
			var i: Int32 = 1
			for val in filter.bindings {
				try val.bindingValue.bind(into: s, at: i)
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
	
	
	
	//MARK: Sync
	
	
	public func get<U: Decodable & Loadable>(_ : U.Type) -> [U] {
		return sync { db in
			return _read(db: db, U.self)
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, limit: Int, page: Int = 1) -> [U] {
		return sync { db in
			return sync { db in
				return _read(db: db, U.self, limit: limit, page: page)
			}
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>) -> [U] {
		return sync { db in
			return sync { db in
				return _read(db: db, U.self, filter: filter)
			}
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>, limit: Int, page: Int = 1) -> [U] {
		return sync { db in
			return sync { db in
				return _read(db: db, U.self, filter: filter, limit: limit, page: page)
			}
		}
	}
	
	
	
	
	//MARK: Async
	
	public func get<U: Decodable & Loadable>(_ : U.Type, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(self._read(db: db, U.self))
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, limit: Int, page: Int = 1, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(self._read(db: db, U.self, limit: limit, page: page))
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(self._read(db: db, U.self, filter: filter))
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>, limit: Int, page: Int = 1, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			handler(self._read(db: db, U.self, filter: filter, limit: limit, page: page))
		}
	}
	
}
