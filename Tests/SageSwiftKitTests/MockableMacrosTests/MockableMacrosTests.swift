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
    
    class PlayingObjectMock: PlayingObject {
         init() {
        }
         var tmpFunc_valueCallsCount: Int = 0
         var tmpFunc_valueCalled: Bool {
            tmpFunc_valueCallsCount > 0
        }
         var tmpFunc_valueParameters: String? {
            self.tmpFunc_valueParametersCalls.last
        }
         var tmpFunc_valueParametersCalls: [(String)] = []
         var tmpFunc_valueReturnValue: Int!


            func tmpFunc(value: String) -> Int {
            self.tmpFunc_valueCallsCount += 1
            self.tmpFunc_valueParametersCalls.append(value)
            return self.tmpFunc_valueReturnValue
        }
    }
    """,
    macros: mockableMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    enum TestError: Error {
        case noValue
    }
    
    @AutoMockable
    public protocol ProtocolToTest {
        func fetchPeriodsList(
            employeeId: Int,
            startDate: Date?,
            endDate: Date?
        ) -> AnyPublisher<[Int], TestError>
        
        func fetchDetailPeriod(
            employeeId: Int,
            period: Double
        ) -> AnyPublisher<Int, TestError>
        
        func fetchDetailPeriod(
            employeeId: Int,
            date: Date
        ) -> AnyPublisher<Double, TestError>
        
        func detailPeriodCache(date: Date) -> TestError?
        func fetchCommentsAndChangelog(
            employeeId: Int64,
            date: Date
        ) -> AnyPublisher<Int, TestError>
        
        func saveWorkDay(
            employeeId: Int64,
            date: Date,
            from: Date,
            to: Date,
            breakStart: Date?,
            breakEnd: Date?,
            breakLength: Int,
            comments: [Bool]
        ) -> AnyPublisher<Int, TestError>
        func cancelTimesheet(employeeId: Int64, period: Bool) -> AnyPublisher<Bool, TestError>
        
        func submitTimesheet(
            employeeId: Int64,
            period: Bool,
            overtime: Int?
        ) -> AnyPublisher<Bool, TestError>
        
        func fetchGeofencingZones(
            employeeId: Int64,
            cache: Bool
        ) -> AnyPublisher<Int, TestError>
        
        func fetchCurrentUser() -> AnyPublisher<Int, TestError>
        
        func updatePermission(
            employeeId: Int64,
            consent: Bool?,
            deviceEnable: Bool?
        ) -> AnyPublisher<Bool, TestError>
    }
    
    func testProtocol() {
        let mockProtocol: ProtocolToTestMock = ProtocolToTestMock()
        
        XCTAssertEqual(mockProtocol.detailPeriodCache(date: Date()), nil)
        mockProtocol.detailPeriodCache_dateReturnValue = .noValue
        
        XCTAssertEqual(mockProtocol.detailPeriodCache(date: Date()), .noValue)
    }
}
