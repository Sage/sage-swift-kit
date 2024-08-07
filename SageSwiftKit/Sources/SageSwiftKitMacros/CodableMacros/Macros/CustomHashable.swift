//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum CustomHashable: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        var syntax: [ExtensionDeclSyntax] = []
        let initObject = SyntaxNodeString.init(
            stringLiteral: "extension \(type.trimmed): Hashable"
        )
        
        let params = CodeBlockItemSyntaxBuilder(
            code: prepareParams(
                node: node,
                members: declaration.memberBlock.members
            )
        )
        let builder = FunctionDeclSyntaxBuilder(
            declaration: "public func hash(into hasher: inout Hasher)"
        )
        builder.addItem(item: params)
        
        do {
            let extensionObject = try ExtensionDeclSyntax.init(initObject) {
                try builder.build()
            }
            syntax.append(extensionObject)
        } catch {
            context.addDiagnostics(from: error, node: node)
        }
        
        return syntax
    }
    
    private static func prepareParams(
        node: AttributeSyntax,
        members: MemberBlockItemListSyntax
    ) -> String {
        let parameters = node
            .adapter
            .findArgument(id: "parameters")?
            .adapter
            .strings()
        
        guard let parameters = parameters else { return "" }
        
        var stringValue = """
        """
        
        let names: [String] = members.compactMap { member -> String? in
            guard let casted = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            
            return casted.bindings.first?.pattern.description
        }
        
        let validParams: [String] = parameters
            .compactMap { param -> String? in
                if names.contains(param) {
                    return param
                }
                
                return nil
        }
        
        for item in validParams {
            stringValue.append("hasher.combine(\(item))")
        }
        
        return stringValue
    }
}
