//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class CustomHashableTests: XCTestCase {
    func testMacro() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomHashable(parameters: ["value", "value1"])
    struct PlayingObject {
        var value: String?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String?
    }
    
    extension PlayingObject: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(value)
        }
    }
    """,
    macros: codableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testMacroTwoKeys() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomHashable(parameters: ["value", "value1"])
    struct PlayingObject {
        var value: String?
        var value1: String?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String?
        var value1: String?
    }
    
    extension PlayingObject: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(value)
            hasher.combine(value1)
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
