//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class CustomDecodableTests: XCTestCase {
    func testCustomDefault() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @CustomDefault(defaultValue: "default_value")
        var value: String
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: String
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            self.value = try container.decodeIfPresent(String.self, forKey: .value) ?? "default_value"
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
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
    
    func testCustomDate() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @CustomDate(dateFormat: "yyyy-mm-dd", defaultValue: Date())
        var value: Date
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: Date
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let tmpValue = try? container.decode(String.self, forKey: .value) {
                dateFormatter.dateFormat = "yyyy-mm-dd"
                let date = dateFormatter.date(from: tmpValue)
                self.value = date ?? Date()
            } else {
                self.value = Date()
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd"
            try container.encode(dateFormatter.string(from: value), forKey: .value)
        }
    }
    """,
    macros: codableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testCustomDateOptional() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @CustomDate(dateFormat: "yyyy-mm-dd")
        var value: Date?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: Date?
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let tmpValue = try? container.decode(String.self, forKey: .value) {
                dateFormatter.dateFormat = "yyyy-mm-dd"
                let date = dateFormatter.date(from: tmpValue)
                self.value = date
            } else {
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let value {
                dateFormatter.dateFormat = "yyyy-mm-dd"
                try container.encode(dateFormatter.string(from: value), forKey: .value)
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
    
    func testCustomURL() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @CustomURL
        var value: URL?
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var value: URL?
    
        enum CodingKeys: String, CodingKey {
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let urlString = try container.decodeIfPresent(String.self, forKey: .value) {
                self.value = URL(string: urlString)
            } else {
                self.value = nil
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
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
    
    func testStringOrInt() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @StringOrInt
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
            let dateFormatter = DateFormatter()
            if let tmpValue = try? container.decode(String.self, forKey: .value) {
                value = tmpValue
            } else {
                if let tmpValue = try? container.decode(Int.self, forKey: .value) {
                    value = String(tmpValue)
                } else {
                    value = nil
                }
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
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
    
    func testStringOrDouble() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @StringOrDouble
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
            let dateFormatter = DateFormatter()
            if let tmpValue = try? container.decode(String.self, forKey: .value) {
                value = tmpValue
            } else {
                if let tmpValue = try? container.decode(Double.self, forKey: .value) {
                    value = String(tmpValue)
                } else {
                    value = nil
                }
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
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
