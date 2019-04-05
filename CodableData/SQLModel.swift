//
//  Saveable.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


public protocol SQLModel {
	associatedtype PrimaryKey: Bindable & Equatable
	var id: PrimaryKey { get }
	static var tableName: String { get }
}

extension SQLModel {
	public static var tableName: String {
		return String(reflecting: Self.self).sqlFormatted()
	}
}

public protocol UUIDModel: SQLModel where PrimaryKey == UUID {
	var id: UUID { get }
}

public protocol RowModel: SQLModel where PrimaryKey == Int64? {
	var id: Int64? { get }
}

struct Paper: Codable, UUIDModel {
	let id: UUID
}

extension Paper: Filterable {
	enum CodingKeys: String, CodingKey {
		case id
	}
	typealias FilterKey = CodingKeys
	static func key<T>(for path: KeyPath<Paper, T>) -> Paper.FilterKey where T : Bindable {
		switch path {
		case \Paper.id:
			return .id
		default:
			fatalError("Unknown key path")
		}
	}
}



extension String {
	
	func sqlFormatted() -> String {
		var result = self
		print("---- Table Name ----\nBefore:\t\(result)")
		if result.hasSuffix(".type") {
			var i = result.endIndex
			result.formIndex(&i, offsetBy: -5)
			result.removeSubrange(i...)
		}
		print("After: \t\(result)")
		
		print("NAME IS '\(result)'")
		if result.hasPrefix("__lldb_expr_") {
			print("Clipping '\(result)'")
			let range = result.range(of: ".")!
			result.removeSubrange(result.startIndex...range.lowerBound)
			result = "PlaygroundModel." + result
			print("Done '\(result)'")
		}
		
		return result
	}
	
}


//TODO: Implement SQLRowModel to allow tables that use row id as the primary key

//public typealias SQLRowModel = Codable & RowModel & Filterable
//public protocol RowModel {
//	var id: Int64? { get }
//}
