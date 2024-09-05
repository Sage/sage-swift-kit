//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

struct CobableMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CustomCodable.self,
        CustomHashable.self,
        CustomEquatable.self,
        CustomCodableKey.self,
        CustomDefault.self,
        CustomDate.self,
        CustomURL.self,
        StringOrInt.self,
        StringToDouble.self
    ]
}
