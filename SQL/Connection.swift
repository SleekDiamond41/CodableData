//
//  Connection.swift
//  SQL
//
//  Created by Michael Arrington on 3/30/19.
//  Copyright © 2019 Duct Ape Productions. All rights reserved.
//

import Foundation
import SQLite3


public class Connection {
	
	public let id: UUID
	
	let db: OpaquePointer
	
	private let queue: DispatchQueue
	
	
	deinit {
		let status = Status(sqlite3_close(db))
		guard status == .ok else {
			fatalError()
		}
	}
	
	
	private init(_ db: OpaquePointer, queue: DispatchQueue) {
		self.id = UUID()
		self.db = db
		self.queue = queue
	}
	
	public convenience init(dir: URL, name: String, queue: DispatchQueue) {
		
		let url = dir.appendingPathComponent(name).appendingPathExtension("sqlite3")//.removingPercentEncoding!
		print("Opening connection to SQL database to:", url.path)
		
		if !FileManager.default.fileExists(atPath: url.path) {
			print("Directory doesn't exist")
			do {
				try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false)
			} catch let error as NSError {
				guard error.code == 516 else {
					fatalError(String(reflecting: error))
				}
			}
		} else {
			print("Directory exists")
		}
		
		var db: OpaquePointer!
		let status = Status(sqlite3_open(url.path, &db))
		guard db != nil else {
			fatalError()
		}
		guard status == .ok else {
			fatalError()
		}
		self.init(db, queue: queue)
	}
	
	convenience init(_ configuration: Database.Configuration, queue: DispatchQueue) {
		self.init(dir: configuration.directory, name: configuration.filename, queue: queue)
	}
	
	public func sync<T>(_ block: () -> T) -> T {
		return queue.sync {
			return block()
		}
	}
	
	public func async(_ block: @escaping () -> Void) {
		queue.async {
			block()
		}
	}
	
}
