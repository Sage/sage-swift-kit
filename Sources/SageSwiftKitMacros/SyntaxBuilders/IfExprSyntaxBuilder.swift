//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

class IfExprSyntaxBuilder: SyntaxBuilder<CodeBlockItemListSyntax> {
    let condition: String
    let body: [CodeBlockItemSyntaxBuilder]
    let elseBody: [CodeBlockItemSyntaxBuilder]?
    
    init(
        condition: String,
        body: [CodeBlockItemSyntaxBuilder],
        elseBody: [CodeBlockItemSyntaxBuilder]? = nil
    ) {
        self.condition = condition
        self.body = body
        self.elseBody = elseBody
    }
    
    private func ifSyntax() throws -> IfExprSyntax {
        try IfExprSyntax(
            .init(stringLiteral: condition),
            bodyBuilder: {
                for line in body {
                    try line.build()
                }
            },
            else: {
                if let elseBody {
                    for line in elseBody {
                        try line.build()
                    }
                }
            })
    }
    
    override func build() throws -> CodeBlockItemListSyntax {
        return try .init(itemsBuilder: {
            ExprSyntax(try ifSyntax())
        })
    }
}
