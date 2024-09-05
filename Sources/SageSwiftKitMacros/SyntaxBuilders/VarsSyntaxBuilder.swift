//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

struct VarsSyntaxBuilder {
    let keyword: TokenSyntax
    let name: TokenSyntax
    let value: ExprSyntaxProtocol
    
    init(
        keyword: Keyword,
        name: String,
        value: ExprSyntaxProtocol
    ) {
        self.keyword = .keyword(keyword)
        self.name = TokenSyntax(stringLiteral: name)
        self.value = value
    }
    
    var build: VariableDeclSyntax {
        VariableDeclSyntax(
            bindingSpecifier: keyword,
            bindings: PatternBindingListSyntax(itemsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: name),
                    initializer: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: value
                    )
                )
            })
        )
    }
}
