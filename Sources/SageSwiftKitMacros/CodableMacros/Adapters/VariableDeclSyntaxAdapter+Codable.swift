//
// Copyright © 2025 Sage.
// All Rights Reserved.

import SwiftSyntax

extension VariableDeclSyntaxAdapter {
    func getAttributeFor(macro: CodingMacro) -> AttributeSyntax? {
        attributes.first { $0.adapter.name == macro.name }
    }
}
