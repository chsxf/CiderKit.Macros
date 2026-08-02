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

let helloWorld = "Hello, World!"

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
    
    func testExecutingMacro() throws {
        let t = TestStructWithMacros(i: 10, b: true, s: helloWorld)
        assert(t.i == 10)
        assert(t.b)
        assert(t.s == helloWorld)
        
        let t2 = t.mutated(withB: false)
        assert(t2.i == 10)
        assert(t2.b == false)
        assert(t2.s == helloWorld)
        
        let t3 = t.mutated(withI: 20)
        assert(t3.i == 20)
        assert(t3.b == true)
        assert(t3.s == helloWorld)
        
        let t4 = t2.mutated(withI: 30)
        assert(t4.i == 30)
        assert(t4.b == false)
        assert(t4.s == helloWorld)
    }
}
