//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct DecoderBuilder {
    let syntaxBuilder: InitializerDeclSyntaxBuilder
    let nestedKey: String?
    let vars: [VariableDeclSyntax]
    let dateFormatter: String
    
    init(
        nestedKey: String?,
        vars: [VariableDeclSyntax],
        dateFormatter: String
    ) {
        self.nestedKey = nestedKey
        self.vars = vars
        self.syntaxBuilder = .init(
            declaration: "public init(from decoder: any Decoder) throws"
        )
        self.dateFormatter = dateFormatter
    }
    
    func build() throws -> DeclSyntax {
        if let nestedContainer {
            syntaxBuilder.addItem(item: nestedContainer)
        }
        
        syntaxBuilder.addItem(item: container)
        
        syntaxBuilder.addItem(
            item: CodeBlockItemSyntaxBuilder.code( "let \(dateFormatter) = DateFormatter()")
        )
        
        for variable in vars {
            syntaxBuilder.addItem(
                item: DecodeVariableBuild(
                    variable: variable,
                    dateFormatter: dateFormatter
                ).build()
            )
        }
        
        return DeclSyntax(try syntaxBuilder.build())
    }
    
    var nestedContainer: CodeBlockItemSyntaxBuilder? {
        if nestedKey == nil { return nil }
        
        return .code("let nestedContainer = try decoder.container(keyedBy: NestedCodingKeys.self)")
    }
    
    var container: CodeBlockItemSyntaxBuilder {
        if let nestedKey {
            return .code("let container = try nestedContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .\(nestedKey))")
        } else {
            return .code("let container = try decoder.container(keyedBy: CodingKeys.self)")
        }
    }
}
