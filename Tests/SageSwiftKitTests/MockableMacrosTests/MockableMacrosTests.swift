//
// Copyright © 2024 Sage.
// All Rights Reserved.


import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class MockableMacrosTests: XCTestCase {
    func testMacro() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @AutoMockable
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
    
    class PlayingObjectMock: PlayingObject {
         init() {
        }
         var tmpFuncCallsCount: Int = 0
         var tmpFuncCalled: Bool {
            tmpFuncCallsCount > 0
        }
         var tmpFuncParameters: (value: String)? {
            self.tmpFuncParametersCalls.last
        }
         var tmpFuncParametersCalls: [(value: String)] = []
         var tmpFuncReturnValue: Int!
    
    
            func tmpFunc(value: String) -> Int {
            self.tmpFuncCallsCount += 1
            self.tmpFuncParametersCalls.append((value: value))
            return self.tmpFuncReturnValue
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
