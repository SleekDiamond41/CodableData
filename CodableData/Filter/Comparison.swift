//
//  Comparison.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


public enum Comparison<T>: Rule where T: Bindable & Comparable {
	case greater(than: T)
	case less(than: T)
	case between(T, and: T)
	case notBetween(T, and: T)
	
	var query: (String, [T]) {
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


extension Filter {
	
	public init<T>(_ path: KeyPath<Element, T>, is rule: Comparison<T>) where T: Bindable & Comparable {
		self.init(path: path, rule: rule)
	}
	
	public func and<T>(_ path: KeyPath<Element, T>, is rule: Comparison<T>) -> Filter where T: Bindable & Comparable {
		return and(path: path, rule: rule)
	}
	
	public func or<T>(_ path: KeyPath<Element, T>, is rule: Comparison<T>) -> Filter where T: Bindable & Comparable {
		return or(path: path, rule: rule)
	}
	
}
