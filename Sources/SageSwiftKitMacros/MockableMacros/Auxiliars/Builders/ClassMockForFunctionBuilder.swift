//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

// Creates the mock for each function with its parameters calls retun value etc...
struct ClassMockForFunctionBuilder {
    let funcData: FunctionsMockData
    
    var parametersName: String { "Parameters" }
    var callsName: String { "calls" }
    
    init(funcData: FunctionsMockData) {
        self.funcData = funcData
    }
    
    func build() -> ClassDeclSyntax {
        ClassDeclSyntax(
            modifiers: .init(
                itemsBuilder: {
                    .init(name: funcData.accessLevel)
                }
            ),
            name: funcData.className.tokenSyntax,
            memberBlock: .init(
                members: .init(
                    itemsBuilder: {
                        if let parametersStruct = buildParameters() {
                            parametersStruct
                        }
                        
                        buildCalls()
                        buildLastCall()
                        
                        buildCalled()
                        
                        if let returnValue = funcData.returnValue {
                            VariableDeclSyntax(
                                modifiers: .init(itemsBuilder: {
                                    .init(name: funcData.accessLevel)
                                }),
                                Keyword.var,
                                name: "returnValue",
                                type: TypeAnnotationSyntax(
                                    type: TypeSyntax(stringLiteral: returnValue)
                                )
                            )
                        }
                        
                        InitializerDeclSyntax(
                            signature: .init(parameterClause: .init(
                                parameters: .init(itemsBuilder: {
                                    
                                })
                            )),
                            body: .init(statements: .init(itemsBuilder: {
                                
                            }))
                        )
                    }
                )
            )
        )
    }
}

extension ClassMockForFunctionBuilder {
    func buildParameters() -> StructDeclSyntax? {
        return StructDeclSyntax(
            modifiers: .init(itemsBuilder: {
                .init(name: funcData.accessLevel)
            }),
            name: parametersName.tokenSyntax,
            memberBlock: .init(members: .init(itemsBuilder: {
                for parameter in funcData.params {
                    VariableDeclSyntax(
                        modifiers: .init(itemsBuilder: {
                            .init(name: funcData.accessLevel)
                        }),
                        Keyword.let,
                        name: PatternSyntax(stringLiteral: parameter.name),
                        type: TypeAnnotationSyntax(
                            type: TypeSyntax(stringLiteral: parameter.noEscapingType)
                        )
                    )
                }
            }))
        )
    }
    
    func buildCalls() -> VariableDeclSyntax {
        return VariableDeclSyntax(
            modifiers: .init(itemsBuilder: {
                .init(name: funcData.accessLevel)
            }),
            Keyword.var,
            name: .init(stringLiteral: callsName),
            type: TypeAnnotationSyntax(
                type: TypeSyntax(stringLiteral: "[\(parametersName)]")
            ),
            initializer: InitializerClauseSyntax(
                value: ArrayExprSyntax(elements: .init(itemsBuilder: {
                    
                }))
            )
        )
    }
    
    func buildCalled() -> VariableDeclSyntax {
        return VariableDeclSyntax(
            modifiers: .init(itemsBuilder: {
                .init(name: funcData.accessLevel)
            }),
            bindingSpecifier: .keyword(.var),
            bindings: .init(itemsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "called"),
                    typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: "Bool")),
                    accessorBlock: AccessorBlockSyntax(
                        leftBrace: .leftBraceToken(),
                        accessors: .init(CodeBlockItemListSyntax(itemsBuilder: {
                            ReturnStmtSyntax(
                                returnKeyword: .keyword(.return),
                                expression: DeclReferenceExprSyntax(
                                    baseName: "self.lastCall != nil".tokenSyntax
                                )
                            )
                        })),
                        rightBrace: .rightBraceToken()
                    )
                )
            })
        )
    }
    
    func buildLastCall() -> VariableDeclSyntax {
        return VariableDeclSyntax(
            modifiers: .init(itemsBuilder: {
                .init(name: funcData.accessLevel)
            }),
            bindingSpecifier: .keyword(.var),
            bindings: .init(itemsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "lastCall"),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: OptionalTypeSyntax(
                            wrappedType: IdentifierTypeSyntax(name: parametersName.tokenSyntax)
                        )
                    ),
                    accessorBlock: AccessorBlockSyntax(
                        leftBrace: .leftBraceToken(),
                        accessors: .init(CodeBlockItemListSyntax(itemsBuilder: {
                            ReturnStmtSyntax(
                                returnKeyword: .keyword(.return),
                                expression: DeclReferenceExprSyntax(
                                    baseName: "self.calls.last".tokenSyntax
                                )
                            )
                        })),
                        rightBrace: .rightBraceToken()
                    )
                )
            })
        )
    }
}
