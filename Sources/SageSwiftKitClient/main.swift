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


//@NodePrinter
public class TmpClass {
    var a: String
    var b: String
    
    init(a: String, b: String) {
        self.a = a
        self.b = b
    }
}

@AutoMockable(classInheritance: true)
public protocol DateSelectorViewModel: TmpClass {
    var onTap: (String, Int?) -> Void { get set }
    var onString: String { get set }
    var onDouble: Double? { get set }
}
 
