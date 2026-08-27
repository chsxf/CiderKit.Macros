import SwiftSyntaxMacrosTestSupport
import XCTest

final class MutableStructOptionalExpansionTests: XCTestCase {
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

    func testExpansionWithMutableStructOptionalProperty() throws {
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
}
