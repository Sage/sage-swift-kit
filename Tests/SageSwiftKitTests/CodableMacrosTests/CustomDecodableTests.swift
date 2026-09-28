//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SageSwiftKit
import Foundation
import XCTest

@CustomCodable()
struct StringOrDoubleModel: Codable {
    @StringOrDouble
    var value: String?
}

@JsonMockable(keyDecodingStrategy: .convertFromSnakeCase, bundle: .main)
@CustomCodable()
struct NumericStringOrDoubleModel: Codable {
    @StringOrDouble
    let hours: Double
    @StringOrDouble
    let optionalHours: Double?
}

final class CustomDecodableTests: XCTestCase {
    func testStringOrDoubleDecoding() throws {
        let decoder = JSONDecoder()

        let stringValue = try decoder.decode(StringOrDoubleModel.self, from: Data(#"{"value":"12.5"}"#.utf8))
        let doubleValue = try decoder.decode(StringOrDoubleModel.self, from: Data(#"{"value":12.5}"#.utf8))
        let missingValue = try decoder.decode(StringOrDoubleModel.self, from: Data("{}".utf8))

        XCTAssertEqual(stringValue.value, "12.5")
        XCTAssertEqual(doubleValue.value, "12.5")
        XCTAssertNil(missingValue.value)
    }

    func testStringOrDoubleNumericDecoding() throws {
        let decoder = JSONDecoder()

        let stringValue = try decoder.decode(NumericStringOrDoubleModel.self, from: Data(#"{"hours":"12.5","optionalHours":"2.25"}"#.utf8))
        let doubleValue = try decoder.decode(NumericStringOrDoubleModel.self, from: Data(#"{"hours":12.5,"optionalHours":2.25}"#.utf8))
        let missingOptional = try decoder.decode(NumericStringOrDoubleModel.self, from: Data(#"{"hours":12.5}"#.utf8))

        XCTAssertEqual(stringValue.hours, 12.5)
        XCTAssertEqual(stringValue.optionalHours, 2.25)
        XCTAssertEqual(doubleValue.hours, 12.5)
        XCTAssertEqual(doubleValue.optionalHours, 2.25)
        XCTAssertNil(missingOptional.optionalHours)
        XCTAssertThrowsError(try decoder.decode(NumericStringOrDoubleModel.self, from: Data(#"{"hours":"invalid"}"#.utf8)))
    }

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
            self.value = try container.decodeIfPresent(String.self, forKey: .value) ?? "default_value"
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
    
    func testCustomDate() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        var valueA: String
        @CustomDate(dateFormat: "yyyy-mm-dd", defaultValue: Date())
        var value: Date
    }
    """,
    expandedSource: """
    struct PlayingObject {
        var valueA: String
        var value: Date
    
        enum CodingKeys: String, CodingKey {
            case valueA
            case value
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            self.valueA = try container.decode(String.self, forKey: .valueA)
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
            try container.encode(valueA, forKey: .valueA)
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
            if let urlString = try container.decodeIfPresent(String.self, forKey: .value) {
                self.value = URL(string: urlString)
            } else {
                self.value = nil
            }
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
    @CustomCodable()
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

    func testStringOrDoubleWithDoubleProperty() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable()
    struct PlayingObject {
        @StringOrDouble
        let hours: Double
    }
    """,
    expandedSource: """
    struct PlayingObject {
        let hours: Double

        enum CodingKeys: String, CodingKey {
            case hours
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let tmpHours = try? container.decode(Double.self, forKey: .hours) {
                hours = tmpHours
            } else {
                let tmpHours = try container.decode(String.self, forKey: .hours)
                guard let convertedValue = Double(tmpHours) else {
                    throw DecodingError.dataCorruptedError(forKey: .hours, in: container, debugDescription: "Expected a Double or numeric string")
                }
                hours = convertedValue
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(hours, forKey: .hours)
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
