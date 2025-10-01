//
// Copyright © 2025 Sage.
// All Rights Reserved.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class CustomDateTests: XCTestCase {
    func testNormal() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @CustomCodable
    struct PlayingObject {
        @CustomDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", defaultValue: Date())
        public var createdAt: Date
    }
    """,
    expandedSource: """
    struct PlayingObject {
        public var createdAt: Date
    
        enum CodingKeys: String, CodingKey {
            case createdAt
        }
    
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            if let tmpCreatedat = try? container.decode(String.self, forKey: .createdAt) {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let date = dateFormatter.date(from: tmpCreatedat)
                self.createdAt = date ?? Date()
            } else {
                self.createdAt = Date()
            }
        }
    
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
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
