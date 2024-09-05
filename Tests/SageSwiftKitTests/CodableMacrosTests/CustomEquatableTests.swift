//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class CustomEquatableTests: XCTestCase {
    func testMacro() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomEquatable(parameters: ["value", "value1"])
    struct PlayingObject {
        var value: String?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String?
    }
    
    extension PlayingObject: Equatable {
        public static func == (lhs: PlayingObject, rhs: PlayingObject) -> Bool {
            lhs.value == rhs.value
        }
    }
    """,
    macros: codableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
