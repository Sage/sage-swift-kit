//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

struct Argument {
    let label: TokenSyntax
    let expression: DeclReferenceExprSyntax
    
    init(label: TokenSyntax, expression: DeclReferenceExprSyntax) {
        self.label = label
        self.expression = expression
    }
}


struct ArgumentsSyntaxBuilder {
    let arguments: [Argument]
    
    init(arguments: [Argument]) {
        self.arguments = arguments
    }
    
    
    var build: LabeledExprListSyntax {
        .init(itemsBuilder: {
            for arg in arguments {
                LabeledExprSyntax(
                    label: arg.label,
                    colon: .colonToken(),
                    expression: arg.expression
                )
            }
        })
    }
}
