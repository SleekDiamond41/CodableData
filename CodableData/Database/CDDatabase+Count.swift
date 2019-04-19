//
//  Database+Count.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation
import SQLite3


extension CDDatabase {
	
	static func count<U>(_ db: OpaquePointer, _ : U.Type, query: String, bindings: [CDBindable]) -> Int where U: Decodable & CDModel {
		guard let table = CDDatabase._table(db: db, named: U.tableName) else {
			print("No such table")
			return 0
		}
		
		assert(!query.hasSuffix(";"))
		var q = ""
		if query.count > 0 {
			q += " " + query
		}
		
		var s = Statement("SELECT COUNT(*) FROM \(table.name)" + q + ";")
		do {
			try s.prepare(in: db)
			defer {
				s.finalize()
			}
			
			var i: Int32 = 1
			for b in bindings {
				try b.bindingValue.bind(into: s, at: i)
				i += 1
			}
			
			let status = try s.step()
			
			guard status == .row else {
				print(String(reflecting: status))
				return 0
			}
			
			return try Int.unbind(from: s, at: 0)
			
		} catch {
			print(String(reflecting: error))
			return 0
		}
	}
	
	fileprivate static func count<U>(_ db: OpaquePointer, _: U.Type) -> Int where U: Decodable & CDModel {
		return count(db, U.self, query: "", bindings: [])
	}
	
	fileprivate static func count<U>(_ db: OpaquePointer, filter: CDFilter<U>) -> Int where U: Decodable & CDModel {
		return count(db, U.self, query: filter.query, bindings: filter.bindings)
	}
	
}


//MARK: - Sync
extension CDDatabase {
	
	public func count<T>(_ : T.Type) -> Int where T: Decodable & CDModel {
		return sync { return CDDatabase.count($0, T.self) }
	}
	
	public func count<T>(with filter: CDFilter<T>) -> Int where T: Decodable & CDModel {
		return sync { return CDDatabase.count($0, filter: filter) }
	}
	
}


//MARK: - Async
extension CDDatabase {
	
	public func count<T>(_ : T.Type, _ handler: @escaping (Int) -> Void) where T: Decodable & CDModel {
		async { handler(CDDatabase.count($0, T.self)) }
	}
	
	public func count<T>(where filter: CDFilter<T>, _ handler: @escaping (Int) -> Void) where T: Decodable & CDModel {
		async { handler(CDDatabase.count($0, filter: filter)) }
	}
	
}
