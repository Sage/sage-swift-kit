//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

struct ProtocolFunctionsConformanceBuilder {
    let data: FunctionsMockData
    
    init(data: FunctionsMockData) {
        self.data = data
    }
    
    var mockEntity: String {
        "self.\(AutoMockable.mocksVarName).\(data.nameToIdentify)"
    }
    
    func build() throws -> FunctionDeclSyntax {
        return FunctionDeclSyntax(
            attributes: data.syntax.attributes,
            modifiers: .init(itemsBuilder: {
                .init(name: data.accessLevel)
            }),
            name: data.name,
            signature: data.syntax.signature,
            body: .init(statements: .init(itemsBuilder: {
                buildCall()
                
                if data.needThrows {
                    buildThrow()
                }
                
                if data.returnValue != nil {
                    buildReturn()
                }
            }))
        )
    }
    
    private func buildCall() -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(
                baseName: "\(mockEntity).calls.append".tokenSyntax
            ),
            leftParen: .leftParenToken(),
            arguments: .init(itemsBuilder: {
                LabeledExprSyntax(expression: FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        period: .periodToken(),
                        declName: DeclReferenceExprSyntax(baseName: "init".tokenSyntax)
                    ),
                    leftParen: .leftParenToken(),
                    arguments: .init(itemsBuilder: {
                        for param in data.params {
                            LabeledExprSyntax(
                                label: param.name,
                                expression: DeclReferenceExprSyntax(
                                    baseName: param.name.tokenSyntax
                                )
                            )
                        }
                    }),
                    rightParen: .rightParenToken()
                ))
            }),
            rightParen: .rightParenToken()
        )
    }
    
    private func buildThrow() -> CodeBlockItemSyntax {
        CodeBlockItemSyntax(
            item: .expr(ExprSyntax(
                fromProtocol: IfExprSyntax(
                    conditions: ConditionElementListSyntax(itemsBuilder: {
                        OptionalBindingConditionSyntax(
                            bindingSpecifier: .keyword(.let),
                            pattern: IdentifierPatternSyntax(identifier: "error"),
                            initializer: InitializerClauseSyntax(
                                equal: .equalToken(),
                                value: DeclReferenceExprSyntax(
                                    baseName: "\(mockEntity).returnError".tokenSyntax
                                )
                            )
                        )
                    }),
                    body: CodeBlockSyntax(
                        statements: .init(itemsBuilder: {
                            ThrowStmtSyntax(expression: DeclReferenceExprSyntax(baseName: "error"))
                        })
                    )
                )
            ))
        )
    }
    
    private func buildReturn() -> ReturnStmtSyntax {
        return ReturnStmtSyntax(
            returnKeyword: .keyword(.return),
            expression: DeclReferenceExprSyntax(
                baseName: "\(mockEntity).returnValue".tokenSyntax
            )
        )
    }
}
