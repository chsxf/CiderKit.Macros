import SwiftSyntaxMacrosTestSupport
import XCTest

final class ExistingMemberExpansionTests: XCTestCase {
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
}
