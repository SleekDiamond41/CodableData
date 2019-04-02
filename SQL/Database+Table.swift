//
//  Database+Table.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	public func create(_ table: Table) {
		execute(table.query(for: .create))
	}
	
	public func create(_ table: Table, _ handler: @escaping () -> Void) {
		execute(table.query(for: .create), handler)
	}
	
	public func drop(_ table: Table) {
		execute(table.query(for: .drop))
	}
	
	public func drop(_ table: Table, _ handler: @escaping () -> Void) {
		execute(table.query(for: .drop), handler)
	}
	
	public func _table(db: OpaquePointer, named name: String) -> Table? {
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
			
			return Table(name: name, columns: columns)
			
		} catch {
			fatalError(String(reflecting: error))
		}
	}
	
	public func table(_ name: String) -> Table? {
		return sync {
			return _table(db: $0, named: name)
		}
	}
	
	public func table(_ name: String, _ handler: @escaping (Table?) -> Void) {
		async {
			handler(self._table(db: $0, named: name))
		}
	}
	
	public func add(column: Table.Column, to table: inout Table) {
		sync { (db) in
			let query = table.query(for: .addColumn(column))
			_execute(db: db, query)
			table = self._table(db: db, named: table.name)!
		}
	}
	
	public func add(column: Table.Column, to table: Table, _ handler: @escaping (Table) -> Void) {
		async { (db) in
			let query = table.query(for: .addColumn(column))
			self._execute(db: db, query)
			handler(self._table(db: db, named: table.name)!)
		}
	}
	
}
