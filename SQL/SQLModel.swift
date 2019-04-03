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
}


//TODO: Implement SQLRowModel to allow tables that use row id as the primary key

//public typealias SQLRowModel = Codable & RowModel & Filterable
//public protocol RowModel {
//	var id: Int64? { get }
//}
