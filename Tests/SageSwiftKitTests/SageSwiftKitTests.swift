//
// Copyright © 2024 Sage.
// All Rights Reserved.

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

#if canImport(SageSwiftKitMacros)
import SageSwiftKitMacros

let codableMacros: [String: Macro.Type] = [
    "CustomCodable": CustomCodable.self,
    "CustomCodableKey": CustomCodableKey.self,
    "CustomEquatable": CustomEquatable.self,
    "CustomHashable": CustomHashable.self,
    "CustomDefault": CustomDefault.self,
    "CustomDate": CustomDate.self,
    "CustomURL": CustomURL.self,
    "StringOrInt": StringOrInt.self,
    "StringOrDouble": StringOrDouble.self,
    "StringToDouble": StringToDouble.self
]

let mockableMacros: [String: Macro.Type] = [
    "AutoMockable": AutoMockable.self
]

let jsonMockableMacros: [String: Macro.Type] = [
    "JsonMockable": JsonMockable.self
]
#endif
