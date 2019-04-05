import CodableData
import Foundation


protocol Test {}

extension String: Test {}
extension Int: Test {}

struct Phone: Codable, UUIDModel {
	let id: UUID
	let color: Color
	
	enum Color: Int, Codable {
		case red = 1
		case blue = 2
	}
	
	enum CodingKeys: String, CodingKey {
		case id
		case color
	}

	typealias FilterKey = CodingKeys

	static func key<T>(for path: KeyPath<Phone, T>) -> Phone.FilterKey where T : Bindable {
		switch path {
		case \Phone.id:
			return .id
		default:
			fatalError("Unknown KeyPath")
		}
	}
}
//do {
//	let value = Phone.Color.blue
//	print(String(describing: value))
//	let data = try JSONEncoder().encode(["value": value])
////	let data = try JSONSerialization.data(withJSONObject: ["value": value])
//	if let str = String(data: data, encoding: .utf8) {
//		print(str)
//	} else {
//		print("No string?")
//	}
//} catch {
//	print(String(reflecting: error))
//}


let value = Phone.Color.blue


import PlaygroundSupport

let shared = playgroundSharedDataDirectory
let dir = shared.appendingPathComponent("CodableData")//.appendingPathComponent("Database")
let config = Database.Configuration(dir: dir)
let db = Database(config)

let id = UUID(uuidString: "46E45ED5-F36E-46A4-8BBF-525488BA77C7")!
let phone = Phone(id: id, color: .blue)


print(phone)
db.save(phone)

let results = db.get(Phone.self)


let first = results.first { $0.id == id }!
print(first.id)
print(first.color)


print("Done")



//	Phone(id: 46E45ED5-F36E-46A4-8BBF-525488BA77C6)
//	Phone(id: 46E45ED5-F36E-46A4-8BBF-525488BA77C6)
