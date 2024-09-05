//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

struct MockableMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutoMockable.self
    ]
}
