//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation

@attached(peer)
public macro CustomCodableKey(name: String) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomCodableKey")

@attached(peer)
public macro CustomDefault(defaultValue: Any) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomDefault")

@attached(peer)
public macro CustomDate(dateFormat: String, defaultValue: Date? = nil) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomDate")

@attached(member, names: arbitrary)
public macro CustomCodable(nestedProperty: String? = nil) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomCodable")

@attached(peer)
public macro StringOrInt() = #externalMacro(module: "SageSwiftKitMacros", type: "StringOrInt")

@attached(peer)
public macro StringOrDouble() = #externalMacro(module: "SageSwiftKitMacros", type: "StringOrDouble")

@attached(peer)
public macro StringToDouble() = #externalMacro(module: "SageSwiftKitMacros", type: "StringToDouble")

@attached(peer)
public macro CustomURL() = #externalMacro(module: "SageSwiftKitMacros", type: "CustomURL")
