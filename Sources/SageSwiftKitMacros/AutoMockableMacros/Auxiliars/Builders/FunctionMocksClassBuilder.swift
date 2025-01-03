//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

struct FunctionMocksClassBuilder {
    let functions: [FunctionsMockData]
    let accessLevel: TokenSyntax
    
    init(
        functions: [FunctionsMockData],
        accessLevel: TokenSyntax
    ) {
        self.functions = functions
        self.accessLevel = accessLevel
    }
    
    func build() -> ClassDeclSyntax {
        .init(
            modifiers: .init(itemsBuilder: {
                .init(name: accessLevel)
            }),
            name: "FunctionMocks",
            memberBlock: .init(
                members: .init(itemsBuilder: {
                    for function in functions {
                        buildFuncCall(function: function)
                    }
                })
            )
        )
    }
    
    func buildVarForTheClass() -> VariableDeclSyntax {
        VariableDeclSyntax(
            modifiers: .init(itemsBuilder: {
                .init(name: accessLevel)
            }),
            Keyword.var,
            name: .init(stringLiteral: AutoMockable.mocksVarName),
            initializer: InitializerClauseSyntax(value: ExprSyntax(stringLiteral: "FunctionMocks()"))
        )
    }
}

extension FunctionMocksClassBuilder {
    private func buildFuncCall(function: FunctionsMockData) -> VariableDeclSyntax {
        return .init(
            modifiers: .init(itemsBuilder: {
                .init(name: accessLevel)
            }),
            Keyword.var,
            name: .init(stringLiteral: function.nameToIdentify),
            initializer: InitializerClauseSyntax(value: ExprSyntax(stringLiteral: "\(function.className)()"))
        )
    }
}
