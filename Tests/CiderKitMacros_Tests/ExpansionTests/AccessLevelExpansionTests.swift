import SwiftSyntaxMacrosTestSupport
import XCTest

final class AccessLevelExpansionTests: XCTestCase {
    func testImplicitInternalExpansion() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStruct {
                @MutatingProperty let i: Int
            }
            """,
            expandedSource:
            """
            struct TestStruct {
                let i: Int

                init(
                    i: Int
                ) {
                    self.i = i
                }

                func mutated(withI newI: Int) -> Self {
                    .init(i: newI)
                }
            }
            """,
            macros: testMacros)
    }

    func testInternalStructPublicPropertyExpansion() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            struct TestStruct {
                @MutatingProperty public let i: Int
            }
            """,
            expandedSource:
            """
            struct TestStruct {
                public let i: Int

                init(
                    i: Int
                ) {
                    self.i = i
                }

                public func mutated(withI newI: Int) -> Self {
                    .init(i: newI)
                }
            }
            """,
            macros: testMacros)
    }

    func testPublicStructInternalPropertyExpansion() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            public struct TestStruct {
                @MutatingProperty let i: Int
            }
            """,
            expandedSource:
            """
            public struct TestStruct {
                let i: Int

                public init(
                    i: Int
                ) {
                    self.i = i
                }

                func mutated(withI newI: Int) -> Self {
                    .init(i: newI)
                }
            }
            """,
            macros: testMacros)
    }

    func testMixedAccessLevelsExpansion() throws {
        assertMacroExpansion(
            """
            @MutableStruct
            public struct TestStruct {
                @MutatingProperty public let i: Int
                @MutatingProperty private let b: Bool
                @MutatingProperty fileprivate let s: String
                @MutatingProperty package let f: Float
                @MutatingProperty let d: Double
            }
            """,
            expandedSource:
            """
            public struct TestStruct {
                public let i: Int
                private let b: Bool
                fileprivate let s: String
                package let f: Float
                let d: Double

                public init(
                    i: Int,
                    b: Bool,
                    s: String,
                    f: Float,
                    d: Double
                ) {
                    self.i = i
                    self.b = b
                    self.s = s
                    self.f = f
                    self.d = d
                }

                public func mutated(withI newI: Int) -> Self {
                    .init(i: newI, b: b, s: s, f: f, d: d)
                }

                private func mutated(withB newB: Bool) -> Self {
                    .init(i: i, b: newB, s: s, f: f, d: d)
                }

                fileprivate func mutated(withS newS: String) -> Self {
                    .init(i: i, b: b, s: newS, f: f, d: d)
                }

                package func mutated(withF newF: Float) -> Self {
                    .init(i: i, b: b, s: s, f: newF, d: d)
                }

                func mutated(withD newD: Double) -> Self {
                    .init(i: i, b: b, s: s, f: f, d: newD)
                }
            }
            """,
            macros: testMacros)
    }
}
