//
// Copyright © 2024 Sage.
// All Rights Reserved.
import SageSwiftKit
import Foundation
import Combine

struct SubObject: Codable {
    let id: Int
    let name: String
}

@CustomCodable
struct PlayingObject {

    @StringOrInt
    var value: String?
    
    @StringOrDouble
    var sum: String?

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


@AutoMockable()
public protocol DateSelectorViewModel {
    func make() throws -> String
}
