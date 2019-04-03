//
//  Database+Table.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


//MARK: - Get Existing
extension Database {
	
	static func _table(db: OpaquePointer, named name: String) -> Table? {
		var s = Statement("PRAGMA TABLE_INFO(\(name))")
		
		do {
			
			try s.prepare(in: db)
			defer {
				s.finalize()
			}
			
			var columns = [Table.Column]()
			var status = try s.step()
			
			while status == .row {
				
				columns.append(
					Table.Column(
						name: try String.unbind(from: s, at: 1),
						type: try ColumnType.unbind(from: s, at: 2),
						isPrimaryKey: try Bool.unbind(from: s, at: 5))
				)
				status = try s.step()
			}
			
			if columns.count > 0 {
				return Table(name: name, columns: columns)
			} else {
				return nil
			}
			
		} catch {
			fatalError(String(reflecting: error))
		}
	}
	
	func table(_ name: String) -> Table? {
		return sync {
			return Database._table(db: $0, named: name)
		}
	}
	
	func table(_ name: String, _ handler: @escaping (Table?) -> Void) {
		async {
			handler(Database._table(db: $0, named: name))
		}
	}
	
}


//MARK: - Create
extension Database {
	
	static func _create(db: OpaquePointer, _ table: Table) {
		Database._execute(db: db, table.query(for: .create))
	}
	
	func create(_ table: Table) {
		sync { (db) in
			Database._create(db: db, table)
		}
	}
	
	func create(_ table: Table, _ handler: @escaping () -> Void) {
		async { (db) in
			Database._create(db: db, table)
			handler()
		}
	}
	
}


//MARK: - Drop
extension Database {
	
	static func _drop(db: OpaquePointer, _ table: Table) {
		_execute(db: db, table.query(for: .drop))
	}
	
	func drop(_ table: Table) {
		sync { (db) in
			Database._drop(db: db, table)
		}
	}
	
	func drop(_ table: Table, _ handler: @escaping () -> Void) {
		async { (db) in
			Database._drop(db: db, table)
			handler()
		}
	}
	
}
