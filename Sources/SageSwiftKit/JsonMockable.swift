//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation


@attached(member, names: named(jsonMock))
public macro JsonMockable(
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy,
    bundle: Bundle,
    jsonFile: String? = nil
) = #externalMacro(module: "SageSwiftKitMacros", type: "JsonMockable")
