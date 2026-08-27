import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CiderKitMacros_Macros

let testMacros: [String: Macro.Type] = [
    "MutableStruct": MutableStructMacro.self,
    "MutableStructOptional": MutableStructOptionalMacro.self,
    "MutatingProperty": MutatingPropertyMacro.self
]

let helloWorld = "Hello, World!"

final class CiderKitMacros_Tests: XCTestCase {
    func testExpansion() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStruct {
                @MutatingProperty public let a: Int
                public let b: String
                @MutatingProperty public let c: Bool
            }
            """,
            expandedSource:
            """
            struct TestStruct {
                public let a: Int
                public let b: String
                public let c: Bool

                public init(
                    a: Int,
                    b: String,
                    c: Bool
                ) {
                    self.a = a
                    self.b = b
                    self.c = c
                }

                public func mutated(withA newA: Int) -> Self {
                    .init(a: newA, b: b, c: c)
                }

                public func mutated(withC newC: Bool) -> Self {
                    .init(a: a, b: b, c: newC)
                }
            }
            """,
            macros: testMacros
        )
    }

    func testExpansionMacroWithoutProperties() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStruct {
                public let a: Int
                public let b: String
                public let c: Bool
            }
            """,
            expandedSource:
            """
            struct TestStruct {
                public let a: Int
                public let b: String
                public let c: Bool
            }
            """,
            macros: testMacros
        )
    }

    func testExpansionPropertiesWithoutMacro() throws {
        assertMacroExpansion(
            """
            struct TestStruct {
                @MutatingProperty public let a: Int
                public let b: String
                @MutatingProperty public let c: Bool
            }
            """,
            expandedSource:
            """
            struct TestStruct {
                public let a: Int
                public let b: String
                public let c: Bool
            }
            """,
            macros: testMacros
        )
    }

    func testExpansionWithOptionalProperty() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStructWithOptional {
                @MutatingProperty public let i: Int
                @MutatingProperty public let b: Bool
                public let s: String
                @MutableStructOptional(defaultValue: "1.2") public let initOptionalProperty: Float
                @MutableStructOptional(defaultValue: "3.4", keepValueDuringMutation: false) public let initOptionalProperty2: Float
            }
            """,
            expandedSource:
            """
            struct TestStructWithOptional {
                public let i: Int
                public let b: Bool
                public let s: String
                public let initOptionalProperty: Float
                public let initOptionalProperty2: Float

                public init(
                    i: Int,
                    b: Bool,
                    s: String,
                    initOptionalProperty: Float? = nil,
                    initOptionalProperty2: Float? = nil
                ) {
                    self.i = i
                    self.b = b
                    self.s = s
                    self.initOptionalProperty = initOptionalProperty ?? 1.2
                    self.initOptionalProperty2 = initOptionalProperty2 ?? 3.4
                }

                public func mutated(withI newI: Int) -> Self {
                    .init(i: newI, b: b, s: s, initOptionalProperty: initOptionalProperty)
                }

                public func mutated(withB newB: Bool) -> Self {
                    .init(i: i, b: newB, s: s, initOptionalProperty: initOptionalProperty)
                }
            }
            """,
            macros: testMacros)
    }

    func testExpansionWithMutatingOptionalProperty() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStructWithMutatingOptional {
                @MutableStructOptional(defaultValue: "1.2") @MutatingProperty public let initOptionalProperty: Float
                @MutableStructOptional(defaultValue: "3.4", keepValueDuringMutation: false) @MutatingProperty public let initOptionalProperty2: Float
                @MutatingProperty public let i: Int
                @MutatingProperty public let b: Bool
                public let s: String
            }
            """,
            expandedSource:
            """
            struct TestStructWithMutatingOptional {
                public let initOptionalProperty: Float
                public let initOptionalProperty2: Float
                public let i: Int
                public let b: Bool
                public let s: String

                public init(
                    i: Int,
                    b: Bool,
                    s: String,
                    initOptionalProperty: Float? = nil,
                    initOptionalProperty2: Float? = nil
                ) {
                    self.i = i
                    self.b = b
                    self.s = s
                    self.initOptionalProperty = initOptionalProperty ?? 1.2
                    self.initOptionalProperty2 = initOptionalProperty2 ?? 3.4
                }

                public func mutated(withInitOptionalProperty newInitOptionalProperty: Float) -> Self {
                    .init(i: i, b: b, s: s, initOptionalProperty: newInitOptionalProperty)
                }

                public func mutated(withInitOptionalProperty2 newInitOptionalProperty2: Float) -> Self {
                    .init(i: i, b: b, s: s, initOptionalProperty: initOptionalProperty, initOptionalProperty2: newInitOptionalProperty2)
                }

                public func mutated(withI newI: Int) -> Self {
                    .init(i: newI, b: b, s: s, initOptionalProperty: initOptionalProperty)
                }

                public func mutated(withB newB: Bool) -> Self {
                    .init(i: i, b: newB, s: s, initOptionalProperty: initOptionalProperty)
                }
            }
            """,
            macros: testMacros)
    }

    func testExpansionWithExistingFunction() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStructWithPreexistingFunction {
                @MutatingProperty public let a: Int
                @MutatingProperty public let b: Int

                func mutated(withA newA: Int) -> Self {
                    .init(a: newA, b: b + newA)
                }
            }
            """,
            expandedSource:
            """
            struct TestStructWithPreexistingFunction {
                public let a: Int
                public let b: Int

                func mutated(withA newA: Int) -> Self {
                    .init(a: newA, b: b + newA)
                }

                public init(
                    a: Int,
                    b: Int
                ) {
                    self.a = a
                    self.b = b
                }

                public func mutated(withB newB: Int) -> Self {
                    .init(a: a, b: newB)
                }
            }
            """,
            macros: testMacros)
    }

    func testExpansionWithExistingInitializer() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStructWithPreexistingFunction {
                @MutatingProperty public let a: Int
                @MutatingProperty public let b: Int

                public init(a: Int, b: Int) {
                    self.a = a
                    self.b = a + b
                }
            }
            """,
            expandedSource:
            """
            struct TestStructWithPreexistingFunction {
                public let a: Int
                public let b: Int

                public init(a: Int, b: Int) {
                    self.a = a
                    self.b = a + b
                }

                public func mutated(withA newA: Int) -> Self {
                    .init(a: newA, b: b)
                }

                public func mutated(withB newB: Int) -> Self {
                    .init(a: a, b: newB)
                }
            }
            """,
            macros: testMacros)
    }

    func testExpanionWithInitializedMember() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStructWithInitializedMember {
                public let type: String = "test"
                @MutatingProperty public let i: Int
            }
            """,
            expandedSource:
            """
            struct TestStructWithInitializedMember {
                public let type: String = "test"
                public let i: Int

                public init(
                    i: Int
                ) {
                    self.i = i
                }

                public func mutated(withI newI: Int) -> Self {
                    .init(i: newI)
                }
            }
            """,
            macros: testMacros
        )
    }

    func testExecution() {
        let test = TestStruct(i: 10, b: true, s: helloWorld)
        assert(test.i == 10)
        assert(test.b)
        assert(test.s == helloWorld)

        let test2 = test.mutated(withB: false)
        assert(test2.i == 10)
        assert(test2.b == false)
        assert(test2.s == helloWorld)

        let test3 = test.mutated(withI: 20)
        assert(test3.i == 20)
        assert(test3.b == true)
        assert(test3.s == helloWorld)

        let test4 = test2.mutated(withI: 30)
        assert(test4.i == 30)
        assert(test4.b == false)
        assert(test4.s == helloWorld)
    }

    func testExecutionWithOptional() throws {
        let test = TestStructWithOptional(i: 10, b: true, s: helloWorld, initOptionalProperty: 5.4)
        assert(test.i == 10)
        assert(test.b)
        assert(test.s == helloWorld)
        assert(test.initOptionalProperty == 5.4)

        let test2 = test.mutated(withB: false)
        assert(test2.i == 10)
        assert(test2.b == false)
        assert(test2.s == helloWorld)
        assert(test2.initOptionalProperty == 5.4)

        let test3 = TestStructWithOptional(i: 10, b: true, s: helloWorld)
        assert(test3.i == 10)
        assert(test3.b)
        assert(test3.s == helloWorld)
        assert(test3.initOptionalProperty == 1.2)
    }

    func testExecutionWithMutatingOptional() throws {
        let test = TestStructWithMutatingOptional(i: 10, b: true, s: helloWorld, initOptionalProperty: 5.4)
        assert(test.i == 10)
        assert(test.b)
        assert(test.s == helloWorld)
        assert(test.initOptionalProperty == 5.4)

        let test2 = test.mutated(withInitOptionalProperty: 3.6)
        assert(test2.i == 10)
        assert(test2.b)
        assert(test2.s == helloWorld)
        assert(test2.initOptionalProperty == 3.6)

        let test3 = TestStructWithMutatingOptional(i: 10, b: true, s: helloWorld)
        assert(test3.i == 10)
        assert(test3.b)
        assert(test3.s == helloWorld)
        assert(test3.initOptionalProperty == 1.2)

        let test4 = test3.mutated(withInitOptionalProperty: 7.8)
        assert(test4.i == 10)
        assert(test4.b)
        assert(test4.s == helloWorld)
        assert(test4.initOptionalProperty == 7.8)
    }

    func testExecutionWithInitializedMember() throws {
        let test = TestStructWithInitializedMember(i: 10)
        assert(test.type == "test")
        assert(test.i == 10)

        let test2 = test.mutated(withI: 20)
        assert(test2.type == "test")
        assert(test2.i == 20)
    }
}
