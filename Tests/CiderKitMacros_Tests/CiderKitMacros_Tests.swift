import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CiderKitMacros_Macros

let testMacros: [String: Macro.Type] = [
    "MutableStruct": MutableStructMacro.self,
    "MutatingProperty": MutatingPropertyMacro.self
]

final class CiderKitMacros_Tests: XCTestCase {
    func testMacro() throws {
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
    
    func testMacroWithoutProperties() throws {
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
    
    func testPropertiesWithoutMacro() throws {
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
