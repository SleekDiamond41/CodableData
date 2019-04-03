//
//  WhereClause.swift
//  SQL
//
//  Created by Michael Arrington on 4/2/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation

protocol Rule {
	associatedtype T: Bindable
	
	var query: (String, [T]) { get }
}


public struct Filter<Element: Filterable> {
	
	public var query: String {
		return "WHERE " + _query
	}
	
	let _query: String
	let bindings: [Bindable]
	
	
	init(query: String, bindings: [Bindable]) {
		self._query = query
		self.bindings = bindings
	}
	
	public func and(_ filter: Filter) -> Filter {
		let q = "(" + _query + ") AND (" + filter._query + ")"
		return Filter(query: q, bindings: bindings + filter.bindings)
	}
	
	public func or(_ filter: Filter) -> Filter {
		let q = "(" + _query + ") OR (" + filter._query + ")"
		return Filter(query: q, bindings: bindings + filter.bindings)
	}
	
	
	init<T, U>(path: KeyPath<Element, T>, rule: U) where U: Rule, U.T == T {
		let (str, vals) = rule.query
		self._query = "\(Element.key(for: path).stringValue) \(str)"
		self.bindings = vals
	}
	
	func and<T, U>(path: KeyPath<Element, T>, rule: U) -> Filter where U: Rule, U.T == T {
		let (str, vals) = rule.query
		return Filter(query: _query + " AND \(Element.key(for: path).stringValue) \(str)", bindings: bindings + vals)
	}
	
	func or<T, U>(path: KeyPath<Element, T>, rule: U) -> Filter where U: Rule, U.T == T {
		let (str, vals) = rule.query
		return Filter(query: _query + " OR \(Element.key(for: path).stringValue) \(str)", bindings: bindings + vals)
	}
	
}


func test() {
	
//	let ids = (UUID(), UUID(), UUID())
//	
//	let a = Filter<Person>(\.id, is: .equal(to: ids.0))
//		.or(\.id, is: .equal(to: ids.1))
//		.or(\.id, is: .equal(to: ids.2))
//	// WHERE id LIKE ? OR id LIKE ? OR id LIKE ?
//	
//	let b = Filter(\Person.nickName, is: .equal(to: nil))
//	
////	let c = Filter<Person>(\.id, .equal, to: ids.0)
//	
//	
//	
//	let filter = Filter(\Person.name, is: .notEqual(to: "Michael"))
//		.or(\.id, is: .notEqual(to: UUID()))
//		.or(\.name, is: .notEqual(to: "Arrington"))
//		.or(\.id, is: .notEqual(to: UUID()))
}


class MyClass: Equatable {
	static func == (left: MyClass, right: MyClass) -> Bool {
		return left.id == right.id
	}
	
	let id = UUID()
	var name: String = ""
}
