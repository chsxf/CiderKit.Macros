import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

import CiderKitMacros_Macros

let testMacros: [String: Macro.Type] = [
    "MutableStruct": MutableStructMacro.self,
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
                @MutatingProperty public let a: Int
                public let b: String
                @MutatingProperty public let c: Bool
            
                public init(
                    a: Int,
                    b: String,
                    c: Bool
                ) {
                    self.a = a
                    self.b = b
                    self.c = c
                }
            
                public func with(newA: Int) -> Self {
                    .init(a: newA, b: b, c: c)
                }
            
                public func with(newC: Bool) -> Self {
                    .init(a: a, b: b, c: newC)
                }
            }
            """,
            macros: testMacros
        )
    }
}
