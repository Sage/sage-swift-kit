//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

extension AttributeSyntax {
    var adapter: AttributeSyntaxAdapter {
        .init(syntax: self)
    }
}

struct AttributeSyntaxAdapter {
    let syntax: AttributeSyntax
    
    init(syntax: AttributeSyntax) {
        self.syntax = syntax
    }
    
    var name: String {
        syntax.attributeName.as(IdentifierTypeSyntax.self)!.name.text
    }
    
    var arguments: [LabeledExprSyntax] {
        return syntax
            .arguments?
            .as(LabeledExprListSyntax.self)?
            .compactMap { $0 }
        ?? []
    }
    
    func findArgument(id: String) -> LabeledExprSyntax? {
        arguments.first(where: { $0.adapter.identifier == id })
    }
}
