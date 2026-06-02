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

@AutoMockable()
protocol TestProtocolSendable: Sendable {
    var testVar: String { get }
    
    func testFunc() -> Int
}

final class MockableMacrosTests: XCTestCase {
    
    func testSendable() {
        var sut = TestProtocolSendableMock()
        
        sut.testVarReturn = "testVar"
        sut.mock.testFunc.returnValue = 1
        
        XCTAssertEqual(sut.testVar, "testVar")
        XCTAssertEqual(sut.testFunc(), 1)
        XCTAssertEqual(sut.mock.testFunc.called, true)
        XCTAssertEqual(sut.mock.testFunc.calls.count, 1)
        XCTAssertNotNil(sut.mock.testFunc.lastCall)
    }
    
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
    
    internal final class PlayingObjectMock: PlayingObject {
        internal init() {
        }
        internal final class TmpFunc_Value: @unchecked Sendable {
            internal struct ParametersMock: @unchecked Sendable {
                internal let value: String
            }
            internal var calls: [ParametersMock] = []
            internal var lastCall: ParametersMock? {
                return self.calls.last
            }
            internal var called: Bool {
                return self.lastCall != nil
            }
            internal var returnValue: Int!
            init() {
            }
        }
        internal final class FunctionMocks: @unchecked Sendable {
            internal var tmpFunc_Value = TmpFunc_Value()
        }
        internal var mock = FunctionMocks()
        internal var valueReturn: String?
        internal var value: String? {
            get {
                return valueReturn
            }
            set {
                self.valueReturn = newValue
            }
        }
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
