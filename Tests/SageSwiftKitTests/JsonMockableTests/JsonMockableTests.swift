//
// Copyright © 2024 Sage.
// All Rights Reserved.
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SageSwiftKit

final class JsonMockableTests: XCTestCase {
    func testMacroSimple() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
        @JsonMockable(
        keyDecodingStrategy: .convertFromSnakeCase,
        bundle: .main
    )
    struct Example {}
    """,
    expandedSource: """
        
    struct Example {
    
        private static func getMock(bundle: Bundle, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, fileName: String?) throws -> Self {
            let mockURL = bundle.url(forResource: fileName, withExtension: "json")
            guard let mockURL, let data = try? Data(contentsOf: mockURL) else {
                throw NSError(domain: "No data found", code: 500)
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = keyDecodingStrategy
            return try decoder.decode(Example.self, from: data)
        }
    
        public static var jsonMock: Example {
            get throws {
                var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
                    .convertFromSnakeCase
                }
                var bundle: Bundle {
                    .main
                }
                var fileName: String {
                    String(describing: Example.self)
                }
                return try getMock(bundle: bundle, keyDecodingStrategy: keyDecodingStrategy, fileName: fileName)
            }
        }}
    """,
    macros: jsonMockableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testMacroProperties() throws {
        
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
        @JsonMockable(
        keyDecodingStrategy: .useDefaultKeys,
        bundle: .other,
        jsonFile: "customFile"
    )
    struct Example {}
    """,
    expandedSource: """
        
    struct Example {
    
        private static func getMock(bundle: Bundle, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, fileName: String?) throws -> Self {
            let mockURL = bundle.url(forResource: fileName, withExtension: "json")
            guard let mockURL, let data = try? Data(contentsOf: mockURL) else {
                throw NSError(domain: "No data found", code: 500)
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = keyDecodingStrategy
            return try decoder.decode(Example.self, from: data)
        }
    
        public static var jsonMock: Example {
            get throws {
                var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
                    .useDefaultKeys
                }
                var bundle: Bundle {
                    .other
                }
                var fileName: String {
                    "customFile"
                }
                return try getMock(bundle: bundle, keyDecodingStrategy: keyDecodingStrategy, fileName: fileName)
            }
        }}
    """,
    macros: jsonMockableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    @JsonMockable(keyDecodingStrategy: .convertFromSnakeCase, bundle: .module)
    struct Example: Codable {
        let value: String
    }
    
    @JsonMockable(keyDecodingStrategy: .convertFromSnakeCase, bundle: .module, jsonFile: "Example_2")
    struct Example2: Codable {
        let value: String
    }
    
    @JsonMockable(keyDecodingStrategy: .convertFromSnakeCase, bundle: .module, jsonFile: "NotExistent")
    struct ExampleError: Codable {
        let value: String
    }
    
    func testUsage() throws {
        XCTAssertEqual(try Example.jsonMock.value, "one")
        XCTAssertEqual(try Example2.jsonMock.value, "two")
        
        XCTAssertThrowsError(try ExampleError.jsonMock)
    }
}
