//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct EncoderBuilder {
    let syntaxBuilder: FunctionDeclSyntaxBuilder
    let vars: [VariableDeclSyntax]
    let hasCustomDate: Bool
    let dateFormatter: String
    
    init(
        vars: [VariableDeclSyntax],
        hasCustomDate: Bool,
        dateFormatter: String
    ) {
        self.vars = vars
        self.syntaxBuilder = .init(
            declaration: "public func encode(to encoder: Encoder) throws"
        )
        self.dateFormatter = dateFormatter
        self.hasCustomDate = hasCustomDate
    }
    
    func build() throws -> DeclSyntax {
        
        syntaxBuilder.addItem(item: container)
        
        if hasCustomDate {
            syntaxBuilder.addItem(
                item: CodeBlockItemSyntaxBuilder.code("let \(dateFormatter) = DateFormatter()")
            )
        }
        
        for variable in vars {
            syntaxBuilder.addItem(
                item: EncodeVariableBuild(
                    variable: variable,
                    dateFormatter: dateFormatter
                ).build()
            )
        }
        
        return DeclSyntax(try syntaxBuilder.build())
    }
    
    var container: CodeBlockItemSyntaxBuilder {
        .code("var container = encoder.container(keyedBy: CodingKeys.self)")
    }
}
