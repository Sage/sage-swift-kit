//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation

public enum MacroCustomError: CustomStringConvertible, Error {
    case structInit
    
    public var description: String {
        switch self {
            case .structInit:
                return "@DefaultInit can only be applied to a structure"
        }
    }
}
