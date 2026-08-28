import SwiftSyntaxMacrosTestSupport
import XCTest

final class InitializedMemberExpansionTests: XCTestCase {
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
            macros: testMacros
        )
    }
}
