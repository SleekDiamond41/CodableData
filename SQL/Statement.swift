//
//  Statement.swift
//  SQL
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation
import  SQLite3

public struct Statement {
	public let query: String
	private(set) var p: OpaquePointer?
	
	public init(_ query: String) {
		self.query = query
	}
}

extension Statement {
	
	public mutating func prepare(in db: OpaquePointer) throws {
		let status = Status(sqlite3_prepare(db, query, -1, &p, nil))
		guard status == .ok else {
			fatalError()
		}
	}
	public mutating func reset() {
		finalize()
	}
	public func finalize() {
		guard let p = p else { return }
		sqlite3_finalize(p)
	}
	
	@discardableResult
	public func step() throws -> Status {
		assert(p != nil)
		print("Stepping query:\n", query, "\n")
		return Status(sqlite3_step(p))
	}
	
}


extension Statement {
	
	func unbind<T: Unbindable>(_ : T.Type, for key: String, in table: Table) throws -> T {
		guard let index = table.columns.firstIndex(where: { $0.name == key }) else {
			fatalError()
		}
		return try T.unbind(from: self, at: Int32(index))
	}
	
}
