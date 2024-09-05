//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class CustomCodableTests: XCTestCase {
    func testCodable() {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        var value: String?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String?
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.value = try container.decodeIfPresent(String.self, forKey: .value)
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)
        }
    }
    """,
    macros: codableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testNestedCodable() {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable(nestedProperty: "nested_Key")
    struct PlayingObject {
        var value: String?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String?
    
        enum NestedCodingKeys: String, CodingKey {
            case nested_Key
        }
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let nestedContainer = try decoder.container(keyedBy: NestedCodingKeys.self)
            let container = try nestedContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .nested_Key)
            self.value = try container.decodeIfPresent(String.self, forKey: .value)
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)
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