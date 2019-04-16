//
//  Database+Replace.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	private static func replaceAndRead<T>(db: OpaquePointer, _ value: T) -> T where T: SQLModel & Codable {
		let id = value.id
		replace(db: db, value)
		
		return Database.read(db: db, T.self, query: "WHERE id = ? LIMIT 1", bindings: [id]).first!
	}
	
	private static func replace<T>(db: OpaquePointer, _ value: T) where T: SQLModel & Encodable {
		let writer = Writer<T>()
		
		do {
			try writer.prepare(value)
			
			var table: Table! = Database._table(db: db, named: T.tableName)
			
			if table == nil {
				let t = writer.tableDefinition()
				Database._create(db: db, t)
				
				table = Database._table(db: db, named: T.tableName)
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
extension Database {
	
	@discardableResult
	public func save<T>(_ value: T) -> T where T: SQLModel & Codable {
		return sync { db in
			return Database.replaceAndRead(db: db, value)
		}
	}
	
}


//MARK: - Async
extension Database {
	
	public func save<T>(_ value: T, _ handler: @escaping () -> Void) where T: SQLModel & Codable {
		async { db in
			Database.replace(db: db, value)
			handler()
		}
	}
	
	public func save<T>(_ value: T, _ handler: @escaping (T) -> Void) where T: SQLModel & Codable {
		async { db in
			handler(Database.replaceAndRead(db: db, value))
		}
	}
	
}
