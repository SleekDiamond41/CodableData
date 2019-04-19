//
//  Database+Replace.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension CDDatabase {
	
	private static func replaceAndRead<T>(db: OpaquePointer, _ value: T) -> T where T: CDModel & Codable {
		let id = value.id
		replace(db: db, value)
		
		return CDDatabase.get(db, T.self, query: "WHERE id = ? LIMIT 1", bindings: [id]).first!
	}
	
	private static func replace<T>(db: OpaquePointer, _ value: T) where T: CDModel & Encodable {
		let writer = Writer<T>()
		
		do {
			try writer.prepare(value)
			
			var table: Table! = CDDatabase._table(db: db, named: T.tableName)
			
			if table == nil {
				let t = writer.tableDefinition()
				CDDatabase._create(db: db, t)
				
				table = CDDatabase._table(db: db, named: T.tableName)
			}
			
			var a = table!
			
			try writer.replace(value, into: &table, db: db, newColumnsHandler: { columns in
				for c in columns {
					a = _add(db: db, column: c, to: a)
				}
			})
			
		} catch {
			fatalError(String(reflecting: error))
		}
	}
	
}

//MARK: - Sync
extension CDDatabase {
	
//	public func save<T>(_ value: T) where T: SQLModel & Codable {
//		return sync { db in
//			return Database.replace(db: db, value)
//		}
//	}
	@discardableResult
	public func save<T>(_ value: T) -> T where T: CDModel & Codable {
		return sync { db in
			return CDDatabase.replaceAndRead(db: db, value)
		}
	}
	
}


//MARK: - Async
extension CDDatabase {
	
	public func save<T>(_ value: T, _ handler: @escaping () -> Void) where T: CDModel & Codable {
		async { db in
			CDDatabase.replace(db: db, value)
			handler()
		}
	}
	
	public func save<T>(_ value: T, _ handler: @escaping (T) -> Void) where T: CDModel & Codable {
		async { db in
			handler(CDDatabase.replaceAndRead(db: db, value))
		}
	}
	
}
