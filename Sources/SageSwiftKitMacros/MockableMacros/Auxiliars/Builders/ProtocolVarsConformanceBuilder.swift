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
        guard let myType = variable.bindings.first?.typeAnnotation else {
            return nil
        }
        
        guard let typeSyntax = myType.type.as(IdentifierTypeSyntax.self) else {
            return myType
        }
        
        return TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "\(typeSyntax.name.text)!"))
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
