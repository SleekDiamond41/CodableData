
import Foundation
import CodableData
import PlaygroundSupport



let shared = playgroundSharedDataDirectory
let dir = shared.appendingPathComponent("CodableData")//.appendingPathComponent("Database")
let config = CDDatabase.Configuration(dir: dir)
let db = CDDatabase(config)


struct Person: Codable, CDUUIDModel {
	let id: UUID
	let birthday: Date
	var name: String
	var height: Double
	var weight: Double
	
	enum CodingKeys: String, CodingKey {
		case id
		case birthday
		case name
		case height
		case weight
	}
}

extension Person: CDFilterable {
	static func key<T>(for path: KeyPath<Person, T>) -> CodingKeys where T : CDBindable {
		switch path {
		case \Person.birthday:
			return .birthday
		default:
			fatalError()
		}
	}
}


let id = UUID(uuidString: "46E45ED5-F36E-46A4-8BBF-525488BA77C7")!
let birthday = Date()
let name = "Marshal Mathers"
let height = 185.4
let weight = 83.9


let person = Person(id: id, birthday: birthday, name: name, height: height, weight: weight)

let saved = db.save(person)

saved.id == person.id
saved.birthday == person.birthday
saved.name == person.name
saved.height == person.height
saved.weight == person.weight

print(person.birthday)
print(saved.birthday)

print(person.birthday.timeIntervalSince1970)
print(saved.birthday.timeIntervalSince1970)
print(birthday.timeIntervalSince1970)

birthday == person.birthday

let filter = CDFilter<Person>(\.birthday, is: .equal(to: birthday))
let results = db.get(with: filter)
results.count
print(results.first!)

print(person.birthday)
print(saved.birthday)
print(birthday)
print(results.first!.birthday)


birthday == results.first?.birthday
birthday == person.birthday
birthday == saved.birthday

person.birthday == results.first?.birthday



print("Done")
