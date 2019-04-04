import SQL

struct Foo {}

func show(_ first: Bool) {
	let ty: Any.Type
	if first {
		struct Foo {}
		ty = Foo.self
	} else {
		struct Foo {}
		ty = Foo.self
	}
//	print(ty)
//	debugPrint(ty)
//	print(String(describing: ty))
//	print(String(reflecting: ty))
	
	struct F {}
	print(String(describing: F.self))
	print(String(reflecting: F.self))
	print(String(describing: Foo.self))
	print(String(reflecting: Foo.self))
}
show(true)
show(false)
//__lldb_expr_29.(unknown context at $117eab21c).(unknown context at $117eab26c).F
//__lldb_expr_5.(unknown context at $1199ea21c).(unknown context at $1199ea26c).F

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




