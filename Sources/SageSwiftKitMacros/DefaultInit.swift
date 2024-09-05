//
// Copyright © 2024 Sage.
// All Rights Reserved.

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DefaultInit: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroCustomError.structInit
        }
        
        let members = structDecl.memberBlock.members
        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let variablesName = variableDecl.compactMap { $0.bindings.first?.pattern }
        let variablesType = variableDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }
        
        let initializer = try InitializerDeclSyntax(DefaultInit.generateInitialCode(
            variablesName: variablesName,
            variablesType: variablesType)
        ) {
            for name in variablesName {
                ExprSyntax("self.\(name) = \(name)")
            }
        }
        
        return [DeclSyntax(initializer)]
    }
    
    static func generateInitialCode(
        variablesName: [PatternSyntax],
        variablesType: [TypeSyntax]
    ) -> SyntaxNodeString {
        var initialCode: String = "public init(\n"
        for (name, type) in zip(variablesName, variablesType) {
            initialCode += "\(name): \(type), \n"
        }
        initialCode = String(initialCode.dropLast(3))
        initialCode += "\n)"
        return SyntaxNodeString(stringLiteral: initialCode)
    }
}
