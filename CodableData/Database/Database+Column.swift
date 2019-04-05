//
//  Database+Column.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	static func _add(db: OpaquePointer, column: Table.Column, to table: Table) -> Table {
		let query = table.query(for: .addColumn(column))
		Database._execute(db: db, query)
		return Database._table(db: db, named: table.name)!
	}
	
}


//MARK: - Sync
extension Database {
	
	func add(column: Table.Column, to table: inout Table) {
		sync { (db) in
			table = Database._add(db: db, column: column, to: table)
		}
	}
	
}


//MARK: - Async
extension Database {
	
	func add(column: Table.Column, to table: Table, _ handler: @escaping (Table) -> Void) {
		async { (db) in
			handler(Database._add(db: db, column: column, to: table))
		}
	}
	
}
