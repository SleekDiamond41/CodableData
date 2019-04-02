//
//  Database+Replace.swift
//  SQL
//
//  Created by Michael Arrington on 3/31/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


extension Database {
	
	private func _replace(db: OpaquePointer, into table: String, _ bindings: [(String, Bindable)]) {
		let keys = bindings.map { $0.0 }.joined(separator: ", ")
		let values = [String](repeating: "?", count: bindings.count).joined(separator: ", ")
		var s = Statement("REPLACE INTO \(table) (\(keys)) VALUES (\(values))")
		do {
			try s.prepare(in: db)
			defer {
				s.finalize()
			}
			var i: Int32 = 1
			for (_ , value) in bindings {
				try value.bindingValue.bind(into: s, at: i)
				i += 1
			}
			try s.step()
			
		} catch {
			fatalError(String(reflecting: error))
		}
	}
	
	public func replace(into table: String, _ bindings: [(String, Bindable)]) {
		sync {
			_replace(db: $0, into: table, bindings)
		}
	}
	
	public func replace(into table: String, _ bindings: [(String, Bindable)], _ handler: @escaping () -> Void) {
		async {
			self._replace(db: $0, into: table, bindings)
			handler()
		}
	}
	
}
