//
//  Table.swift
//  SQL
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation
import SQLite3


struct Table {
	let name: String
	let columns: [Column]
	
	func query(for action: Action) -> String {
		switch action {
		case .create:
			let c = columns.map { $0.name + " " + $0.type.rawValue }.joined(separator: ", ")
			return "CREATE TABLE IF NOT EXISTS \(name) (\(c));"
		case .addColumn(let col):
			return "ALTER TABLE \(name) ADD COLUMN \(col.name) \(col.type.rawValue);"
		case .drop:
			return "DROP TABLE \(name);"
		}
	}
	
	enum Action {
		case create
		case addColumn(Column)
		case drop
	}
	
	struct Column {
		let name: String
		let type: ColumnType
		let isPrimaryKey: Bool
		
		init(name: String, type: ColumnType, isPrimaryKey: Bool = false) {
			self.name = name
			self.type = type
			self.isPrimaryKey = isPrimaryKey
		}
	}
}
