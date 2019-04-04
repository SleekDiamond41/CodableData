//
//  Database+Replace.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	private static func _replace<T>(db: OpaquePointer, _ value: T) where T: Encodable & UUIDModel {
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
	
	public func save<T>(_ value: T) where T: Encodable & UUIDModel {
		sync { db in
			Database._replace(db: db, value)
		}
	}
	
}


//MARK: - Async
extension Database {
	
	public func save<T>(_ value: T, _ handler: @escaping () -> Void) where T: Encodable & UUIDModel {
		async { db in
			Database._replace(db: db, value)
			handler()
		}
	}
	
}
