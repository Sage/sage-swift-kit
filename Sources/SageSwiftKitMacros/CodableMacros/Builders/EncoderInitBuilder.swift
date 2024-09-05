//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct EncoderInitBuilder {
    let syntaxBuilder: FunctionDeclSyntaxBuilder
    let vars: [VariableDeclSyntax]
    
    init(
        vars: [VariableDeclSyntax]
    ) {
        self.vars = vars
        self.syntaxBuilder = .init(
            declaration: "public func encode(to encoder: Encoder) throws"
        )
    }
    
    func build() throws -> DeclSyntax {
        
        syntaxBuilder.addItem(item: container)
        
        for variable in vars {
            syntaxBuilder.addItem(item: EncodeVariableBuild(variable: variable).build())
        }
        
        return DeclSyntax(try syntaxBuilder.build())
    }
    
    var container: CodeBlockItemSyntaxBuilder {
        .init(code: "var container = encoder.container(keyedBy: CodingKeys.self)")
    }
}
