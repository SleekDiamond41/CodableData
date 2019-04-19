//
//  Saveable.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


public protocol CDModel {
	associatedtype PrimaryKey: CDBindable & Equatable
	var id: PrimaryKey { get }
	static var tableName: String { get }
}

extension CDModel {
	public static var tableName: String {
		return String(reflecting: Self.self).sqlFormatted()
	}
}

public protocol CDUUIDModel: CDModel where PrimaryKey == UUID {
	var id: UUID { get }
}

public protocol CDRowModel: CDModel where PrimaryKey == Int64? {
	var id: Int64? { get }
}

struct Paper: Codable, CDUUIDModel {
	let id: UUID
}

extension Paper: CDFilterable {
	enum CodingKeys: String, CodingKey {
		case id
	}
	typealias FilterKey = CodingKeys
	static func key<T>(for path: KeyPath<Paper, T>) -> Paper.FilterKey where T : CDBindable {
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
		
		if result.hasSuffix(".type") {
			var i = result.endIndex
			result.formIndex(&i, offsetBy: -5)
			result.removeSubrange(i...)
		}
		
		if result.hasPrefix("__lldb_expr_") {
			let range = result.range(of: ".")!
			result.removeSubrange(result.startIndex...range.lowerBound)
			result = "PlaygroundModel." + result
		}
		
		return result
	}
	
}


//TODO: Implement SQLRowModel to allow tables that use row id as the primary key

//public typealias SQLRowModel = Codable & RowModel & CDFilterable
//public protocol RowModel {
//	var id: Int64? { get }
//}
