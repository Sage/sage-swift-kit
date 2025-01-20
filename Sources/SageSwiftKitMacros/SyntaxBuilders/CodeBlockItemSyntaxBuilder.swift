//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

class CodeBlockItemSyntaxBuilder: SyntaxBuilder<CodeBlockItemListSyntax> {
    var otherBuilder: SyntaxBuilder<CodeBlockItemListSyntax>?
    var linesOfCode: [String]?
    
    override init() {
    }
    
    @discardableResult
    func addLine(_ code: String) -> Self {
        if linesOfCode == nil {
            linesOfCode = [code]
        } else {
            linesOfCode?.append(code)
        }
        
        return self
    }
    
    @discardableResult
    func setBuilder(_ otherBuilder: SyntaxBuilder<CodeBlockItemListSyntax>) -> Self {
        self.otherBuilder = otherBuilder
        return self
    }
    
    override func build() throws -> CodeBlockItemListSyntax {
        if let otherBuilder {
            return try otherBuilder.build()
        }
        
        return CodeBlockItemListSyntax(itemsBuilder: {
            for code in linesOfCode ?? [] {
                CodeBlockItemSyntax(stringLiteral: code)
            }
        })
    }
}

// Factory
extension CodeBlockItemSyntaxBuilder {
    static func code(_ code: String) -> CodeBlockItemSyntaxBuilder {
        return .init().addLine(code)
    }
    
    static func builder(_ builder : SyntaxBuilder<CodeBlockItemListSyntax>) -> CodeBlockItemSyntaxBuilder {
        return .init().setBuilder(builder)
    }
}
