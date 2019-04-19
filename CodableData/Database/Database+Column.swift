//
//  Database+Column.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension CDDatabase {
	
	static func _add(db: OpaquePointer, column: Table.Column, to table: Table) -> Table {
		let query = table.query(for: .addColumn(column))
		CDDatabase._execute(db: db, query)
		return CDDatabase._table(db: db, named: table.name)!
	}
	
}


//MARK: - Sync
extension CDDatabase {
	
	func add(column: Table.Column, to table: inout Table) {
		sync { (db) in
			table = CDDatabase._add(db: db, column: column, to: table)
		}
	}
	
}


//MARK: - Async
extension CDDatabase {
	
	func add(column: Table.Column, to table: Table, _ handler: @escaping (Table) -> Void) {
		async { (db) in
			handler(CDDatabase._add(db: db, column: column, to: table))
		}
	}
	
}
