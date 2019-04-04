//
//  Bindable.swift
//  SQL
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation
import SQLite3


public enum SQLValue {
	case text(String)
	case integer(Int64)
	case double(Double)
	case blob(Data)
	case null
	
	func bind(into s: Statement, at index: Int32) throws {
		switch self {
		case .text(let str):
			let status = Status(sqlite3_bind_text(s.p, index, NSString(string: str).utf8String, -1, nil))
			guard status == .ok else {
				fatalError(String(reflecting: status))
			}
		case .integer(let num):
			let status = Status(sqlite3_bind_int64(s.p, index, num))
			guard status == .ok else {
				fatalError(String(reflecting: status))
			}
		case .double(let num):
			let status = Status(sqlite3_bind_double(s.p, index, num))
			guard status == .ok else {
				fatalError(String(reflecting: status))
			}
		case .blob(let d):
			let data = d as NSData
			
			let status = Status(sqlite3_bind_blob(s.p, index, data.bytes, Int32(data.length), nil))
			guard status == .ok else {
				fatalError(String(reflecting: s))
			}
		case .null:
			let status = Status(sqlite3_bind_null(s.p, index))
			guard status == .ok else {
				fatalError(String(reflecting: status))
			}
		}
	}
}


public protocol Bindable {
	var bindingValue: SQLValue { get }
}

extension Optional: Bindable where Wrapped: Bindable {
	public var bindingValue: SQLValue {
		switch self {
		case .none:
			return .null
		case .some(let val):
			return val.bindingValue
		}
	}
}

extension UUID: Bindable {
	public var bindingValue: SQLValue {
		return uuidString.bindingValue
	}
}

extension String: Bindable {
	public var bindingValue: SQLValue {
		return .text(self)
	}
}

extension Int64: Bindable {
	public var bindingValue: SQLValue {
		return .integer(self)
	}
}

extension Int: Bindable {
	public var bindingValue: SQLValue {
		return Int64(self).bindingValue
	}
}

extension Int32: Bindable {
	public var bindingValue: SQLValue {
		return Int64(self).bindingValue
	}
}

extension Int16: Bindable {
	public var bindingValue: SQLValue {
		return Int64(self).bindingValue
	}
}

extension Int8: Bindable {
	public var bindingValue: SQLValue {
		return Int64(self).bindingValue
	}
}

extension Double: Bindable {
	public var bindingValue: SQLValue {
		return .double(self)
	}
}

extension Float: Bindable {
	public var bindingValue: SQLValue {
		return Double(self).bindingValue
	}
}

extension Data: Bindable {
	public var bindingValue: SQLValue {
		return .blob(self)
	}
}

extension Bool: Bindable {
	public var bindingValue: SQLValue {
		return .integer(self ? 1 : 0)
	}
}
