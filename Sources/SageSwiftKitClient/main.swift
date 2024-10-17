//
// Copyright © 2024 Sage.
// All Rights Reserved.
import SageSwiftKit
import Foundation
import Combine

@AutoMockable(accessLevel: "public")
protocol FooProtocol {
    func tmpFunc(var1: @escaping (String?) -> Void, var2: AnyPublisher<Bool, Never>) -> Void
}

let mockProtocol: FooProtocolMock = .init()

struct SubObject: Codable {
    let id: Int
    let name: String
}

@CustomCodable
struct PlayingObject {

    @StringOrInt
    var value: String?

    @CustomURL
    var createdOn: URL?
    
    @StringToDouble
    var start: Double
    
    @CustomDefault(defaultValue: 25)
    var end: Double
    
    @CustomCodableKey(name: "subo")
    var subobject: SubObject
    
    var attachment: String?
    
    var identifier: Int
}


@JsonMockable(
    keyDecodingStrategy: .convertFromSnakeCase,
    bundle: .main
)
struct User: Decodable {
    var example: String
    
    static var mockA: Self {
        get throws {
            try getMock(bundle: .main, keyDecodingStrategy: .convertFromSnakeCase, fileName: "fileA")
        }
    }
    
    static var mockB: Self {
        get throws {
            try getMock(bundle: .main, keyDecodingStrategy: .convertFromSnakeCase, fileName: "fileB")
        }
    }
       
}
