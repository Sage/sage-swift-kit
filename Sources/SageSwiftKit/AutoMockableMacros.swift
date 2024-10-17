//
// Copyright © 2024 Sage.
// All Rights Reserved.

@attached(peer, names: suffixed(Mock))
public macro AutoMockable(accessLevel: String? = nil) = #externalMacro(module: "SageSwiftKitMacros", type: "AutoMockable")
