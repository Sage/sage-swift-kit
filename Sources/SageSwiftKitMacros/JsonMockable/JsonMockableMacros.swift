//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

struct JsonMockableMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JsonMockable.self
    ]
}
