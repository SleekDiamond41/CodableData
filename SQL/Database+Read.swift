//
//  Database+Read.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	private func _read<T: Decodable & Loadable>(db: OpaquePointer, _: T.Type, clause: String? = nil, table: Table) -> [T] {
		
		var query = "SELECT * FROM \(T.tableName)"
		if let clause = clause {
			query += " WHERE " + clause
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
	
//	private func _read<T: Decodable & Loadable>(db: OpaquePointer, _: T.Type, where predicate: String, table: Table) -> [T] {
//		return _read(db: db, T.self, clause: predicate, table: table)
//	}
	
//	private func _read<T: Decodable & Loadable>(db: OpaquePointer, _: T.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], table: Table) -> [T] {
//		var pred = predicate
//		for (rule, clause) in others {
//			pred += (rule == .and ? " AND " : " OR ") + clause
//		}
//		return _read(db: db, T.self, clause: pred, table: table)
//	}
	
	private func _read<T: Decodable & Loadable>(db: OpaquePointer, _: T.Type, where predicate: String, _ others: [(ClauseJoinRule, String)] = [], limit: Int, page: Int, table: Table) -> [T] {
		
		assert(limit > 0)
		assert(page > 0)
		
		var pred = predicate
		for (rule, clause) in others {
			pred += (rule == .and ? " AND " : " OR ") + clause
		}
		pred += " LIMIT \(limit)"
		pred += " OFFSET \((page-1) * limit)" // first page has an offset 0, second page has an offset LIMIT, third page has an offset LIMIT + LIMIT and so on
		return _read(db: db, T.self, clause: pred, table: table)
	}
	
	private func _read<T: Decodable & Loadable>(db: OpaquePointer, _: T.Type, filter: Filter<T>, limit: Int? = nil, page: Int = 1, table: Table) -> [T] {
		
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
	
//	public func get<U: Decodable & Loadable>(_ : U.Type, where predicate: String? = nil) -> [U] {
//		return sync { (db) -> [U] in
//			guard let table = Database._table(db: db, named: U.tableName) else {
//				print("No such table")
//				return []
//			}
//			return _read(db: db, U.self, clause: predicate, table: t)
//		}
//	}
//
//	public func get<U: Decodable & Loadable>(_ : U.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], limit: Int, page: Int = 1) -> [U] {
//		guard let t = table(U.tableName) else {
//			print("No such table")
//			return []
//		}
//
//		return sync {
//			return _read(db: $0, U.self, where: predicate, others, limit: limit, page: page, table: t)
//		}
//	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type) -> [U] {
		return sync { db in
			guard let table = Database._table(db: db, named: U.tableName) else {
				print("No such table")
				return []
			}
			return _read(db: db, U.self, table: table)
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>) -> [U] {
		return sync { db in
			guard let table = Database._table(db: db, named: U.tableName) else {
				print("No such table")
				return []
			}
			return _read(db: db, U.self, filter: filter, table: table)
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>, limit: Int, page: Int = 1) -> [U] {
		return sync { db in
			guard let table = Database._table(db: db, named: U.tableName) else {
				print("No such table")
				return []
			}
			return _read(db: db, U.self, filter: filter, limit: limit, page: page, table: table)
			//			return _read(db: db, U.self, where: predicate, others, table: table)
		}
	}
	
	
	
	
	//MARK: Async
	
//	public func get<U: Decodable & Loadable>(_ : U.Type, where predicate: String? = nil, _ handler: @escaping ([U]) -> Void) {
//		self.async { (db) in
//			guard let t = Database._table(db: db, named: U.tableName) else {
//				print("No such table")
//				handler([])
//				return
//			}
//
//			handler(self._read(db: db, U.self, clause: predicate, table: t))
//		}
//	}
//
//	public func get<U: Decodable & Loadable>(_ : U.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], _ handler: @escaping ([U]) -> Void) {
//		async { (db) in
//			guard let t = Database._table(db: db, named: U.tableName) else {
//				print("No such table")
//				handler([])
//				return
//			}
//
//			handler(self._read(db: db, U.self, where: predicate, others, table: t))
//		}
//	}
//
//	public func get<U: Decodable & Loadable>(_ : U.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], limit: Int, page: Int = 1, _ handler: @escaping ([U]) -> Void) {
//		async { (db) in
//			guard let t = Database._table(db: db, named: U.tableName) else {
//				print("No such table")
//				handler([])
//				return
//			}
//
//			handler(self._read(db: db, U.self, where: predicate, others, limit: limit, page: page, table: t))
//		}
//	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			guard let table = Database._table(db: db, named: U.tableName) else {
				print("No such table")
				handler([])
				return
			}
			
			handler(self._read(db: db, U.self, filter: filter, table: table))
		}
	}
	
	public func get<U: Decodable & Loadable>(_ : U.Type, where filter: Filter<U>, limit: Int, page: Int = 1, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			guard let table = Database._table(db: db, named: U.tableName) else {
				print("No such table")
				handler([])
				return
			}
			
			handler(self._read(db: db, U.self, filter: filter, limit: limit, page: page, table: table))
		}
	}
	
}
