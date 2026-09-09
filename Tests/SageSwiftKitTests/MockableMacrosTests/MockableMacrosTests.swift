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

@AutoMockable()
protocol TestGenericProtocol {
    func identity<T>(_ value: T) -> T
}

@AutoMockable(accessLevel: "public")
public protocol TestActorProtocol: Actor {
    func testFunc() -> Int
    func echo<T>(_ value: T) -> T where T: Sendable
}

final class MockableMacrosTests: XCTestCase {
    
    func testSendable() {
        let sut = TestProtocolSendableMock()
        
        sut.testVarReturn = "testVar"
        sut.mock.testFunc.returnValue = 1
        
        XCTAssertEqual(sut.testVar, "testVar")
        XCTAssertEqual(sut.testFunc(), 1)
        XCTAssertEqual(sut.mock.testFunc.called, true)
        XCTAssertEqual(sut.mock.testFunc.calls.count, 1)
        XCTAssertNotNil(sut.mock.testFunc.lastCall)
    }

    func testGenericFunctionWithT() {
        let sut = TestGenericProtocolMock()
        sut.mock.identity_Value.returnValue = "output"

        let stringResult = sut.identity("input")
        sut.mock.identity_Value.returnValue = 42
        let intResult = sut.identity(7)

        XCTAssertEqual(stringResult, "output")
        XCTAssertEqual(intResult, 42)
        XCTAssertTrue(sut.mock.identity_Value.called)
        XCTAssertEqual(sut.mock.identity_Value.calls.count, 2)
        XCTAssertEqual(sut.mock.identity_Value.calls.first?.value as? String, "input")
        XCTAssertEqual(sut.mock.identity_Value.lastCall?.value as? Int, 7)
    }

    func testGenericFunctionMacroExpansion() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @AutoMockable()
    protocol GenericService {
        func identity<T>(_ value: T) -> T
    }
    """,
    expandedSource: """
    protocol GenericService {
        func identity<T>(_ value: T) -> T
    }

    internal final class GenericServiceMock: GenericService {
        internal init() {
        }
        internal final class Identity_Value: @unchecked Sendable {
            internal struct ParametersMock: @unchecked Sendable {
                internal let value: Any
            }
            internal var calls: [ParametersMock] = []
            internal var lastCall: ParametersMock? {
                return self.calls.last
            }
            internal var called: Bool {
                return self.lastCall != nil
            }
            internal var returnValue: Any?
            init() {
            }
        }
        internal final class FunctionMocks: @unchecked Sendable {
            internal var identity_Value = Identity_Value()
        }
        internal var mock = FunctionMocks()
        internal func identity<T>(_ value: T) -> T {
            self.mock.identity_Value.calls.append(.init(value: value))
            return self.mock.identity_Value.returnValue as! T
        }
    }
    """,
    macros: mockableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testActor() async {
        let sut = TestActorProtocolMock()
        let mocks = await sut.mock
        mocks.testFunc.returnValue = 1
        mocks.echo_Value.returnValue = "generic"

        let result = await sut.testFunc()
        let genericResult = await sut.echo("input")

        XCTAssertEqual(result, 1)
        XCTAssertEqual(genericResult, "generic")
        XCTAssertTrue(mocks.testFunc.called)
        XCTAssertEqual(mocks.testFunc.calls.count, 1)
        XCTAssertNotNil(mocks.testFunc.lastCall)
        XCTAssertEqual(mocks.echo_Value.lastCall?.value as? String, "input")
    }

    func testActorMacroExpansion() throws {
#if canImport(SageSwiftKitMacros)
        assertMacroExpansion(
    """
    @AutoMockable(accessLevel: "public")
    protocol Worker: Actor {
    }
    """,
    expandedSource: """
    protocol Worker: Actor {
    }

    public actor WorkerMock: Worker, Actor {
        public init() {
        }
        public final class FunctionMocks: @unchecked Sendable {
        }
        public var mock = FunctionMocks()
    }
    """,
    macros: mockableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
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
