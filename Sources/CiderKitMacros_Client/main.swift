import CiderKitMacros

@MutableStruct
struct Test: CustomStringConvertible {
    @MutatingProperty public let a: Int
    public let b: String
    @MutatingProperty public let c: Bool
    
    var description: String {
        "a: \(a), b: \(b), c: \(c)"
    }
}

let t = Test(a: 10, b: "Hello, world!", c: false)
print(t)

let t2 = t.mutated(withA: 20)
print(t2)
