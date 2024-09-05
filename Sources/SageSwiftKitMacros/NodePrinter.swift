//
// Copyright © 2024 Sage.
// All Rights Reserved.

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum NodePrinter: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return ["\(raw: declaration.memberBlock.members.debugDescription)"]
    }
}
