//
//  Saveable.swift
//  SQL
//
//  Created by Michael Arrington on 4/3/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation


public typealias DataModel = Saveable & Loadable

public protocol Saveable {
	var id: UUID { get }
}

public protocol Loadable {
	var id: UUID { get }
}
