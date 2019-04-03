import SQL

let a = NSCompoundPredicate(type: .or, subpredicates: [
	NSPredicate(format: "name = %@", "Michael"),
	NSPredicate(format: "id = %i", 1),
	NSPredicate(format: "id = %i", 2),
])

let b = NSCompoundPredicate(type: .or, subpredicates: [
	NSPredicate(format: "id < %d", 200),
	NSPredicate(format: "id > %d", 300),
])

let c = NSCompoundPredicate(type: .and, subpredicates: [
	NSPredicate(format: "id BETWEEN %@", [1, 1000]),
	b
])

let pred = NSCompoundPredicate(type: .and, subpredicates: [a, c])
print(pred.predicateFormat)





print("Done")




