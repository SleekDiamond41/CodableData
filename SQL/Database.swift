//
//  Database.swift
//  SQL
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation

public class Database {
	
	let conns: (Connection, Connection)
	
	init(_ a: Connection, _ b: Connection) {
		self.conns = (a, b)
	}
	
	public convenience init(dir: URL, name: String) {
		self.init(
			Connection(dir: dir, name: name, queue: DispatchQueue(label: "com.SQL.Database.Connection.Sync", qos: .userInteractive)),
			Connection(dir: dir, name: name, queue: DispatchQueue(label: "com.SQL.Database.Connection.Async", qos: .userInteractive))
		)
	}
	
	public convenience init() {
		self.init(
			dir: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("SQL"),
			name: "Data")
	}
	
	func sync<T>(_ block: (OpaquePointer) -> T) -> T {
		return conns.0.sync {
			return block(conns.0.db)
		}
	}
	
	func async(_ block: @escaping (OpaquePointer) -> Void) {
		conns.1.async {
			block(self.conns.1.db)
		}
	}
	
	func _execute(db: OpaquePointer, _ query: String) {
		do {
			var s = Statement(query)
			try s.prepare(in: db)
			defer {
				s.finalize()
			}
			try s.step()
		} catch {
			fatalError(String(reflecting: error))
		}
	}
	
	public func execute(_ query: String) {
		sync { db in
			_execute(db: db, query)
		}
	}
	
	public func execute(_ query: String, _ handler: @escaping () -> Void) {
		async { db in
			self._execute(db: db, query)
			handler()
		}
	}
	
}
