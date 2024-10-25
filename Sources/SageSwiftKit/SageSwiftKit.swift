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

@attached(extension, conformances: Hashable, names: arbitrary)
public macro CustomHashable(parameters: [String]) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomHashable")

@attached(extension, conformances: Equatable, names: arbitrary)
public macro CustomEquatable(parameters: [String]) = #externalMacro(module: "SageSwiftKitMacros", type: "CustomEquatable")

@attached(member, names: arbitrary)
public macro NodePrinter() = #externalMacro(module: "SageSwiftKitMacros", type: "NodePrinter")
