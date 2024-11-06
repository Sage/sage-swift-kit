//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SageSwiftKit
import Foundation
import Combine
import XCTest

final class MockableMacrosTests: XCTestCase {
    func testMacro() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @AutoMockable()
    protocol PlayingObject {
        var value: String? { get }
    
        func tmpFunc(value: String) -> Int
    }
    """,
    expandedSource: """
    protocol PlayingObject {
        var value: String? { get }

        func tmpFunc(value: String) -> Int
    }
    
    internal class PlayingObjectMock: PlayingObject {
        internal init() {
        }
        internal class TmpFunc_Value {
            internal struct Parameters {
                internal let value: String
            }
            internal var calls: [Parameters] = []
            internal var lastCall: Parameters? {
                return self.calls.last
            }
            internal var called: Bool {
                return self.lastCall != nil
            }
            internal var returnValue: Int!
            init() {
            }
        }
        internal class FunctionMocks {
            internal var tmpFunc_Value = TmpFunc_Value()
        }
        internal var mock = FunctionMocks()
        internal var value: String? {
            get {
                return valueReturn
            }
            set {
                self.valueReturn = newValue
            }
        }
        internal var valueReturn: String?
        internal func tmpFunc(value: String) -> Int {
            self.mock.tmpFunc_Value.calls.append(.init(value: value))
            return self.mock.tmpFunc_Value.returnValue
        }
    }
    """,
    macros: mockableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
