//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

struct ProtocolVarsConformanceBuilder {
    let variable: VariableDeclSyntax
    let accessLevel: TokenSyntax
    
    var name: String {
        variable.bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.text
    }
    
    var varReturnName: String {
        name+"Return"
    }
    
    var typeReturnVar: TypeAnnotationSyntax? {
        guard let typeAnnotation = variable.bindings.first?.typeAnnotation else {
            return nil
        }
        
        let type = typeAnnotation.type
        
        if type.as(OptionalTypeSyntax.self) != nil || type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) != nil {
            return typeAnnotation
        }
        
        if let funcType = type.as(FunctionTypeSyntax.self) {
            return TypeAnnotationSyntax(
                type: ImplicitlyUnwrappedOptionalTypeSyntax(
                    wrappedType: TupleTypeSyntax(
                        elements: .init(itemsBuilder: {
                            TupleTypeElementSyntax(
                                type: funcType.trimmed
                            )
                        })
                    )
                )
            )
        }
        
        return TypeAnnotationSyntax(
            type: ImplicitlyUnwrappedOptionalTypeSyntax(
                wrappedType: type.trimmed,
                exclamationMark: .exclamationMarkToken()
            )
        )
    }
    
    init(
        variable: VariableDeclSyntax,
        accessLevel: TokenSyntax
    ) {
        self.variable = variable
        self.accessLevel = accessLevel
    }
    
    func build() -> VariableDeclSyntax {
        return VariableDeclSyntax(
            modifiers: .init(itemsBuilder: {
                .init(name: accessLevel)
            }),
            bindingSpecifier: .keyword(.var),
            bindings: .init(itemsBuilder: {
                .init(
                    pattern: IdentifierPatternSyntax(identifier: name.tokenSyntax),
                    typeAnnotation: variable.bindings.first?.typeAnnotation,
                    accessorBlock: .init(accessors:
                            .accessors(
                                .init(
                                    itemsBuilder: {
                                        AccessorDeclSyntax(
                                            accessorSpecifier: .keyword(.get),
                                            bodyBuilder: {
                                                ReturnStmtSyntax(
                                                    expression: DeclReferenceExprSyntax(baseName: varReturnName.tokenSyntax)
                                                )
                                            }
                                        )
                                        
                                        AccessorDeclSyntax(
                                            accessorSpecifier: .keyword(.set),
                                            bodyBuilder: {
                                                .init(stringLiteral: "self.\(varReturnName) = newValue")
                                            }
                                        )

                                    }
                                )
                            )
                    )
                )
            })
        )
    }
    
    func buildReturnVar() -> VariableDeclSyntax {
        return VariableDeclSyntax(
            modifiers: .init(itemsBuilder: {
                .init(name: accessLevel)
            }),
            bindingSpecifier: .keyword(.var),
            bindings: .init(itemsBuilder: {
                .init(
                    pattern: IdentifierPatternSyntax(identifier: varReturnName.tokenSyntax),
                    typeAnnotation: typeReturnVar
                )
            })
        )
    }
}
