import CiderKitMacros

print("=== Mutable Struct")

@MutableStruct
struct Test: CustomStringConvertible {
    @MainActor private static var test: Int = 10

    @MutatingProperty public let a: Int
    public let b: String
    @MutatingProperty(accessLevel: .fileprivate) public let c: Bool

    var description: String {
        "a: \(a), b: \"\(b)\", c: \(c)"
    }
}

let test = Test(a: 10, b: "Hello, world!", c: false)
print(test)

let test2 = test.mutated(withA: 20)
print(test2)

print("=== Mutable Struct With Optional")

@MutableStruct
struct TestWithOptional: CustomStringConvertible {
    @MutatingProperty public let a: Int
    public let b: String
    @MutatingProperty let c: Bool

    @MutableStructOptional(defaultValue: "123") public let initOptionalProperty: Int
    @MutableStructOptional(defaultValue: "456", keepValueDuringMutation: false) public let initOptionalProperty2: Int

    var description: String {
        "a: \(a), b: \"\(b)\", c: \(c), initOptionalProperty: \(initOptionalProperty), initOptionalProperty2: \(initOptionalProperty2)"
    }
}

let testWithOptional = TestWithOptional(a: 10, b: "Hello, world!", c: false, initOptionalProperty2: 789)
print(testWithOptional)

let testWithOptional2 = testWithOptional.mutated(withA: 20)
print(testWithOptional2)

print("=== Mutable Struct With Mutating Optional")

@MutableStruct
struct TestWithMutatingOptional: CustomStringConvertible {
    @MutableStructOptional(defaultValue: "123") @MutatingProperty public let initOptionalProperty: Int
    @MutableStructOptional(defaultValue: "456", keepValueDuringMutation: false) @MutatingProperty public let initOptionalProperty2: Int

    @MutatingProperty public let a: Int
    public let b: String
    @MutatingProperty public let c: Bool

    var description: String {
        "a: \(a), b: \"\(b)\", c: \(c), initOptionalProperty: \(initOptionalProperty), initOptionalProperty2: \(initOptionalProperty2)"
    }
}

let testWithMutatingOptional = TestWithMutatingOptional(a: 10, b: "Hello, world!", c: false, initOptionalProperty: 680, initOptionalProperty2: 789)
print(testWithMutatingOptional)

let testWithMutatingOptional2 = testWithMutatingOptional.mutated(withInitOptionalProperty: 24)
print(testWithMutatingOptional2)

let testWithMutatingOptional3 = testWithMutatingOptional2.mutated(withInitOptionalProperty2: 101112)
print(testWithMutatingOptional3)

@MutableStruct
struct TestWithInitializedMember: CustomStringConvertible {
    public let type: String = "test"
    @MutatingProperty public let i: Int

    var description: String {
        "type: \(type), i: \(i)"
    }
}
