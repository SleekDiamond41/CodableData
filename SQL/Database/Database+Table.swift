//
//  Database+Table.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	static func _create(db: OpaquePointer, _ table: Table) {
		Database._execute(db: db, table.query(for: .create))
	}
	
	public func create(_ table: Table) {
		sync { (db) in
			Database._create(db: db, table)
		}
	}
	
	public func create(_ table: Table, _ handler: @escaping () -> Void) {
		async { (db) in
			Database._create(db: db, table)
			handler()
		}
	}
	
	public func drop(_ table: Table) {
		execute(table.query(for: .drop))
	}
	
	public func drop(_ table: Table, _ handler: @escaping () -> Void) {
		execute(table.query(for: .drop), handler)
	}
	
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
	
	public func table(_ name: String) -> Table? {
		return sync {
			return Database._table(db: $0, named: name)
		}
	}
	
	public func table(_ name: String, _ handler: @escaping (Table?) -> Void) {
		async {
			handler(Database._table(db: $0, named: name))
		}
	}
	
	func _add(db: OpaquePointer, column: Table.Column, to table: Table) -> Table {
		let query = table.query(for: .addColumn(column))
		Database._execute(db: db, query)
		return Database._table(db: db, named: table.name)!
	}
	
	public func add(column: Table.Column, to table: inout Table) {
		sync { (db) in
			table = _add(db: db, column: column, to: table)
		}
	}
	
	public func add(column: Table.Column, to table: Table, _ handler: @escaping (Table) -> Void) {
		async { (db) in
			handler(self._add(db: db, column: column, to: table))
		}
	}
	
}
