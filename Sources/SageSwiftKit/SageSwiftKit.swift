//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation

@freestanding(expression)
public macro wip(feature: String, todo: String) = #externalMacro(
    module: "SageSwiftKitMacros",
    type: "WipMacro"
)

@attached(member, names: arbitrary)
public macro DefaultInit() = #externalMacro(
    module: "SageSwiftKitMacros",
    type: "DefaultInit"
)

@freestanding(expression)
public macro debug_print(_ description: String) = #externalMacro(
    module: "SageSwiftKitMacros",
    type: "DebugPrint"
)

@attached(peer)
public macro CustomCodableKey(name: String) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomCodableKey")

@attached(peer)
public macro CustomDefault(defaultValue: Any) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomDefault")

@attached(peer)
public macro CustomDate(dateFormat: String, defaultValue: Date? = nil) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomDate")

@attached(member, names: arbitrary)
public macro CustomCodable(nestedProperty: String? = nil) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomCodable")

@attached(extension, conformances: Hashable, names: arbitrary)
public macro CustomHashable(parameters: [String]) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomHashable")

@attached(extension, conformances: Equatable, names: arbitrary)
public macro CustomEquatable(parameters: [String]) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomEquatable")

@attached(peer)
public macro StringOrInt() = #externalMacro(module: "SageSwiftKitMacros", type: "StringOrInt")

@attached(peer)
public macro StringToDouble() = #externalMacro(module: "SageSwiftKitMacros", type: "StringToDouble")

@attached(peer)
public macro CustomURL() = #externalMacro(module: "SageSwiftKitMacros", type: "CustomURL")

@attached(peer, names: suffixed(Mock))
public macro AutoMockable(accessLevel: String? = nil) = #externalMacro(module: "SageSwiftKitMacros", type: "AutoMockable")

@attached(member, names: arbitrary)
public macro NodePrinter() = #externalMacro(module: "SageSwiftKitMacros", type: "NodePrinter")
