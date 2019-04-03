//
//  Database+Replace.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	private func _replace<T>(db: OpaquePointer, _ value: T) where T: Encodable {
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
		
//		let keys = bindings.map { $0.0 }.joined(separator: ", ")
//		let values = [String](repeating: "?", count: bindings.count).joined(separator: ", ")
//		var s = Statement("REPLACE INTO \(table) (\(keys)) VALUES (\(values))")
//		do {
//			try s.prepare(in: db)
//			defer {
//				s.finalize()
//			}
//			var i: Int32 = 1
//			for (_ , value) in bindings {
//				try value.bindingValue.bind(into: s, at: i)
//				i += 1
//			}
//			try s.step()
//
//		} catch {
//			fatalError(String(reflecting: error))
//		}
	}
	
	public func replace<T>(_ value: T) where T: Encodable {
		sync { db in
			_replace(db: db, value)
		}
	}
	
	public func replace<T>(_ value: T, _ handler: @escaping () -> Void) where T: Encodable {
		async { db in
			self._replace(db: db, value)
			handler()
		}
	}
	
}
