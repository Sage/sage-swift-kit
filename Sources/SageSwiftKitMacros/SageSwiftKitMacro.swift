//
// Copyright © 2024 Sage.
// All Rights Reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SageSwiftKitPlugin: CompilerPlugin {
    var providingMacros: [Macro.Type] {
        var macros: [Macro.Type] = [
            WipMacro.self,
            DefaultInit.self,
            DebugPrint.self,
            NodePrinter.self
        ]
        
        macros.append(contentsOf: CobableMacros().providingMacros)
        macros.append(contentsOf: MockableMacros().providingMacros)
        
        return macros
    }
}
