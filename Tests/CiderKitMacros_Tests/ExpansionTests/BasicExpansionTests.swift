import SwiftSyntaxMacrosTestSupport
import XCTest

final class BasicExpansionTests: XCTestCase {
    func testExpansion() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStruct {
                @MutatingProperty public let a: Int
                public let b: String
                @MutatingProperty let c: Bool
            }
            """,
            expandedSource:
            """
            struct TestStruct {
                public let a: Int
                public let b: String
                let c: Bool

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
}
