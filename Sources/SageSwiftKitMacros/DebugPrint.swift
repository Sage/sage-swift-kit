//
// Copyright © 2024 Sage.
// All Rights Reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DebugPrint: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("error: the macro does not have any arguments")
        }
        
        return
            """
            #if DEBUG
                print(\(raw: argument.description))
            #endif
            """
    }
}
