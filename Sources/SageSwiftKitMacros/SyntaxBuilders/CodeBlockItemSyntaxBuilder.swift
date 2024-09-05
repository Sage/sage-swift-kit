//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

class CodeBlockItemSyntaxBuilder: SyntaxBuilder<CodeBlockItemListSyntax> {
    var code: String?
    var otherBuilder: SyntaxBuilder<CodeBlockItemListSyntax>?
    
    init(code: String) {
        self.code = code
    }
    
    init(otherBuilder: SyntaxBuilder<CodeBlockItemListSyntax>) {
        self.otherBuilder = otherBuilder
    }
    
    override func build() throws -> CodeBlockItemListSyntax {
        guard let otherBuilder else {
            return .init(stringLiteral: code ?? "")
        }
        
        return try otherBuilder.build()
    }
}
