//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct DecoderInitBuilder {
    let syntaxBuilder: InitializerDeclSyntaxBuilder
    let nestedKey: String?
    let vars: [VariableDeclSyntax]
    
    init(
        nestedKey: String?,
        vars: [VariableDeclSyntax]
    ) {
        self.nestedKey = nestedKey
        self.vars = vars
        self.syntaxBuilder = .init(
            declaration: "public init(from decoder: any Decoder) throws"
        )
    }
    
    func build() throws -> DeclSyntax {
        if let nestedContainer {
            syntaxBuilder.addItem(item: nestedContainer)
        }
        
        syntaxBuilder.addItem(item: container)
        
        for variable in vars {
            syntaxBuilder.addItem(item: DecodeVariableBuild(variable: variable).build())
        }
        
        return DeclSyntax(try syntaxBuilder.build())
    }
    
    var nestedContainer: CodeBlockItemSyntaxBuilder? {
        if nestedKey == nil { return nil }
        
        return .init(code: "let nestedContainer = try decoder.container(keyedBy: NestedCodingKeys.self)")
    }
    
    var container: CodeBlockItemSyntaxBuilder {
        if let nestedKey {
            return .init(code: "let container = try nestedContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .\(nestedKey))")
        } else {
            return .init(code: "let container = try decoder.container(keyedBy: CodingKeys.self)")
        }
    }
}
