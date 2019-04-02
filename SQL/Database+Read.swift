//
//  Database+Read.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	private func _read<T: Decodable>(db: OpaquePointer, _: T.Type, clause: String? = nil, table: Table) -> [T] {
		
		
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
	
	private func _read<T: Decodable>(db: OpaquePointer, _: T.Type, where predicate: String, table: Table) -> [T] {
		return _read(db: db, T.self, clause: predicate, table: table)
	}
	
	private func _read<T: Decodable>(db: OpaquePointer, _: T.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], table: Table) -> [T] {
		var pred = predicate
		for (rule, clause) in others {
			pred += (rule == .and ? " AND " : " OR ") + clause
		}
		return _read(db: db, T.self, clause: pred, table: table)
	}
	
	private func _read<T: Decodable>(db: OpaquePointer, _: T.Type, where predicate: String, _ others: [(ClauseJoinRule, String)] = [], limit: Int, page: Int, table: Table) -> [T] {
		
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
	
	
	
	//MARK: Sync
	
	public func read<U: Decodable>(_ : U.Type, where predicate: String? = nil) -> [U] {
		guard let t = table(U.tableName) else {
			print("No such table")
			return []
		}
		
		return sync { (db) -> [U] in
			return _read(db: db, U.self, clause: predicate, table: t)
		}
	}
	
	public func read<U: Decodable>(_ : U.Type, where predicate: String, _ others: [(ClauseJoinRule, String)]) -> [U] {
		guard let t = table(U.tableName) else {
			print("No such table")
			return []
		}
		
		return sync {
			return _read(db: $0, U.self, where: predicate, others, table: t)
		}
	}
	
	public func read<U: Decodable>(_ : U.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], limit: Int, page: Int = 1) -> [U] {
		guard let t = table(U.tableName) else {
			print("No such table")
			return []
		}
		
		return sync {
			return _read(db: $0, U.self, where: predicate, others, limit: limit, page: page, table: t)
		}
	}
	
	
	
	//MARK: Async
	
	public func read<U: Decodable>(_ : U.Type, where predicate: String? = nil, _ handler: @escaping ([U]) -> Void) {
		self.async { (db) in
			guard let t = self._table(db: db, named: U.tableName) else {
				print("No such table")
				handler([])
				return
			}
			
			handler(self._read(db: db, U.self, clause: predicate, table: t))
		}
	}
	
	public func read<U: Decodable>(_ : U.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			guard let t = self._table(db: db, named: U.tableName) else {
				print("No such table")
				handler([])
				return
			}
			
			handler(self._read(db: db, U.self, where: predicate, others, table: t))
		}
	}
	
	public func read<U: Decodable>(_ : U.Type, where predicate: String, _ others: [(ClauseJoinRule, String)], limit: Int, page: Int = 1, _ handler: @escaping ([U]) -> Void) {
		async { (db) in
			guard let t = self._table(db: db, named: U.tableName) else {
				print("No such table")
				handler([])
				return
			}
			
			handler(self._read(db: db, U.self, where: predicate, others, limit: limit, page: page, table: t))
		}
	}
	
}
