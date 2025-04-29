//
// Copyright © 2025 Sage.
// All Rights Reserved.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class StringToDoubleTests: XCTestCase {
    
    func testOptional() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @StringToDouble public var value: Double?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        public var value: Double?
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let tmpValue = try? container.decode(String.self, forKey: .value) {
                value = Double(tmpValue) ?? nil
            } else {
                value = nil
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let value {
                try container.encode(String(value), forKey: .value)
            } else {
            }
        }
    }
    """,
    macros: codableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testNoOptional() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @StringToDouble public var value: Double
    }
    """,
    expandedSource: """
    struct PlayingObject {
        public var value: Double
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let tmpValue = try? container.decode(String.self, forKey: .value) {
                value = Double(tmpValue) ?? 0
            } else {
                value = 0
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            try container.encode(String(value), forKey: .value)
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
