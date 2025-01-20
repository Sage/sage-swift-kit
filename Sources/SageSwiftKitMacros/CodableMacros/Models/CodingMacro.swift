//
// Copyright © 2025 Sage.
// All Rights Reserved.

import SwiftSyntax

enum CodingMacro: Identifiable, Equatable {
    case customDefault
    case customDate
    case customURL
    case stringOrInt
    case stringOrDouble
    case stringToDouble
    
    var name: String {
        switch self {
        case .customDefault:
            return String(describing: CustomDefault.self)
        case .customDate:
            return String(describing: CustomDate.self)
        case .customURL:
            return String(describing: CustomURL.self)
        case .stringOrInt:
            return String(describing: StringOrInt.self)
        case .stringOrDouble:
            return String(describing: StringOrDouble.self)
        case .stringToDouble:
            return String(describing: StringToDouble.self)
        }
    }
    
    var id: String { name }
}
