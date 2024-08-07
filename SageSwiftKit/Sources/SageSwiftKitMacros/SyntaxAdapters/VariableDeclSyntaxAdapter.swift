//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

extension VariableDeclSyntax {
    var adapter: VariableDeclSyntaxAdapter {
        .init(syntax: self)
    }
}

struct VariableDeclSyntaxAdapter {
    let syntax: VariableDeclSyntax
    
    init(syntax: VariableDeclSyntax) {
        self.syntax = syntax
    }
    
    var identifier: TokenSyntax {
        syntax.bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier
    }
    
    var typeAnnotation: TypeAnnotationSyntax {
        syntax.bindings.first!.typeAnnotation!
    }
    
    var attributes: [AttributeSyntax] {
        syntax.attributes.compactMap { $0.as(AttributeSyntax.self) }
    }
    
    func findAttribute(name: String) -> AttributeSyntax? {
        attributes.first(where: { $0.adapter.name == name })
    }
}
