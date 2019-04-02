import SQL



let rangeFilter = Person.filter(\.id, is: .between(1, and: 1000))
	.and(\.id, is: .notBetween(200, and: 300))

let other = Person.filter(\.name, is: .equal(to: "Michael"))
	.or(\.id, is: .equal(to: 1))
	.or(\.id, is: .equal(to: 2))

let filter = rangeFilter.and(other)
print(filter.query)
print(filter.bindings)



print("Done")




