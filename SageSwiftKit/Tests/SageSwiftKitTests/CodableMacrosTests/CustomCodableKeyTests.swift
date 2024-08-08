//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class CustomCodableKeyTests: XCTestCase {
    func testNormal() {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @CustomCodableKey(name: "test_key")
        var value: String?
        var otherValue: String
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String?
        var otherValue: String
    
        enum CodingKeys: String, CodingKey {
            case value = "test_key"
            case otherValue
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.value = try container.decodeIfPresent(String.self, forKey: .value)
            self.otherValue = try container.decode(String.self, forKey: .otherValue)
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)
            try container.encode(otherValue, forKey: .otherValue)
        }
    }
    """,
    macros: codableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testNestedCustomCodable() {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable(nestedProperty: "nested_Key")
    struct PlayingObject {
        @CustomCodableKey(name: "test_key")
        var value: String?
        var otherValue: String
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String?
        var otherValue: String
    
        enum NestedCodingKeys: String, CodingKey {
            case nested_Key
        }
    
        enum CodingKeys: String, CodingKey {
            case value = "test_key"
            case otherValue
        }
    
        public init(from decoder: any Decoder) throws {
            let nestedContainer = try decoder.container(keyedBy: NestedCodingKeys.self)
            let container = try nestedContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .nested_Key)
            self.value = try container.decodeIfPresent(String.self, forKey: .value)
            self.otherValue = try container.decode(String.self, forKey: .otherValue)
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)
            try container.encode(otherValue, forKey: .otherValue)
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
