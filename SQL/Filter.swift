//
//  WhereClause.swift
//  SQL
//
//  Created by Michael Arrington on 4/2/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


public struct Filter<Element: BetterFilterable> {
	public private(set) var query: String
	public private(set) var bindings: [Bindable]
	
	private init(query: String, bindings: [Bindable]) {
		self.query = query
		self.bindings = bindings
	}
	
	init<T: Bindable & Equatable>(_ path: KeyPath<Element, T>, is rule: Equality<T>) {
		let (str, vals) = rule.query
		
		self.query = "WHERE \(Element.key(for: path).stringValue) \(str)"
		self.bindings = vals
	}
	
	init<T: Bindable & Comparable>(_ path: KeyPath<Element, T>, is rule: ComparableOperand<T>) {
		let (str, vals) = rule.values
		
		self.query = "WHERE \(Element.key(for: path).stringValue) \(str)"
		self.bindings = vals
	}
	
	public func and<T: Equatable & Bindable>(_ path: KeyPath<Element, T>, is operand: Equality<T>) -> Filter {
		let (str, vals) = operand.query
		
		return Filter(query: query + " AND \(Element.key(for: path).stringValue) \(str)", bindings: bindings + vals)
	}
	
	public func or<T: Equatable & Bindable>(_ path: KeyPath<Element, T>, is operand: Equality<T>) -> Filter {
		let (str, vals) = operand.query
		return Filter(query: query + " OR \(Element.key(for: path).stringValue) \(str)", bindings: bindings + vals)
	}
	
	public func and<T: Bindable & Comparable>(_ path: KeyPath<Element, T>, is operand: ComparableOperand<T>) -> Filter {
		let (str, vals) = operand.values
		return Filter(query: query + " AND \(Element.key(for: path).stringValue) \(str)", bindings: bindings + vals)
	}

	public func or<T: Bindable & Comparable>(_ path: KeyPath<Element, T>, is operand: ComparableOperand<T>) -> Filter {
		let (str, vals) = operand.values
		return Filter(query: query + " OR \(Element.key(for: path).stringValue) \(str)", bindings: bindings + vals)
	}
	
	public func and(_ filter: Filter) -> Filter {
		let q = "(" + query + ") AND (" + filter.query + ")"
		return Filter(query: q, bindings: bindings + filter.bindings)
	}
	
	public func or(_ filter: Filter) -> Filter {
		let q = "(" + query + ") OR (" + filter.query + ")"
		return Filter(query: q, bindings: bindings + filter.bindings)
	}
	
	public enum Rule {
		case `is`
		case isNot
	}
	
	public enum ComparableOperand<T: Comparable> {
		case greater(than: T)
		case less(than: T)
		case between(T, and: T)
		case notBetween(T, and: T)
		
		fileprivate var values: (String, [T]) {
			switch self {
			case .greater(than: let val):
				return ("> ?", [val])
			case .less(than: let val):
				return ("< ?", [val])
			case .between(let a, and: let b):
				assert(a < b)
				return ("BETWEEN ? AND ?", [a, b])
			case .notBetween(let a, and: let b):
				assert(a < b)
				return ("NOT BETWEEN ? AND ?", [a, b])
			}
		}
	}
}


extension BetterFilterable {
	
	public static func filter<T: Bindable & Comparable>(_ path: KeyPath<Self, T>, is rule: Equality<T>) -> Filter<Self> {
		return Filter(path, is: rule)
	}
	
	public static func filter<T: Bindable & Equatable>(_ path: KeyPath<Self, T>, is rule: Filter<Self>.ComparableOperand<T>) -> Filter<Self> {
		return Filter(path, is: rule)
	}
	
}

struct Quick: Codable, DataModel {
	let id: UUID
	
	enum CodingKeys: String, CodingKey {
		case id
	}
}

extension Quick: BetterFilterable {
	typealias FilterKey = CodingKeys
	
	static func key<T>(for path: KeyPath<Quick, T>) -> Quick.FilterKey where T : Bindable {
		switch path {
		case \Quick.id:
			return .id
		default:
			fatalError()
		}
	}
}

func test() {
	
	let ids = (UUID(), UUID(), UUID())
	
	let a = Filter<Person>(\.id, is: .equal(to: ids.0))
		.or(\.id, is: .equal(to: ids.1))
		.or(\.id, is: .equal(to: ids.2))
	// WHERE id LIKE ? OR id LIKE ? OR id LIKE ?
	
	let b = Filter(\Person.nickName, is: .equal(to: nil))
	
//	let c = Filter<Person>(\.id, .equal, to: ids.0)
	
	
	
	let filter = Filter(\Person.name, is: .notEqual(to: "Michael"))
		.or(\.id, is: .notEqual(to: UUID()))
		.or(\.name, is: .notEqual(to: "Arrington"))
		.or(\.id, is: .notEqual(to: UUID()))
}


class MyClass: Equatable {
	static func == (left: MyClass, right: MyClass) -> Bool {
		return left.id == right.id
	}
	
	let id = UUID()
	var name: String = ""
}
