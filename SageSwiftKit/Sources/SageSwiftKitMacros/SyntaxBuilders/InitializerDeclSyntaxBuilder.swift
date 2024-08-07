//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

class InitializerDeclSyntaxBuilder: SyntaxBuilder<InitializerDeclSyntax> {
    let declaration: String
    var bodyItems: [SyntaxBuilder<CodeBlockItemListSyntax>]
    
    init(
        declaration: String
    ) {
        self.declaration = declaration
        self.bodyItems = []
    }
    
    func addItem(item: SyntaxBuilder<CodeBlockItemListSyntax>) {
        self.bodyItems.append(item)
    }
    
    override func build() throws -> InitializerDeclSyntax {
        return try .init(
            SyntaxNodeString(stringLiteral: declaration),
            bodyBuilder: {
                for item in bodyItems {
                    try item.build()
                }
            }
        )
    }
}
