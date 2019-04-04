//
//  Saveable.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


public typealias SQLModel = Codable & UUIDModel & Filterable

public protocol UUIDModel {
	var id: UUID { get }
	
	static var tableName: String { get }
}

extension UUIDModel {
	public static var tableName: String {
		return String(reflecting: Self.self).sqlFormatted()
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
		return "[" + result + "]"
	}
	
	func snakeCased() -> String {
		var result = ""
		
		var i = startIndex
		
		result += self[i].lowercased()
		formIndex(after: &i)
		
		while i < self.endIndex {
			let c = self[i]
			
			if c.isUppercase {
				result += "_" + c.lowercased()
			} else if c == "." {
				result += "_"
			} else {
				result += c.lowercased()
			}
			
			formIndex(after: &i)
		}
		
		return result
	}
}


//TODO: Implement SQLRowModel to allow tables that use row id as the primary key

//public typealias SQLRowModel = Codable & RowModel & Filterable
//public protocol RowModel {
//	var id: Int64? { get }
//}
