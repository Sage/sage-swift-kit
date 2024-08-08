//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum CustomEquatable: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        var syntax: [ExtensionDeclSyntax] = []
        let initObject = SyntaxNodeString.init(
            stringLiteral: "extension \(type.trimmed): Equatable"
        )
        
        let params = CodeBlockItemSyntaxBuilder(code: prepareParams(node: node))
        let builder = FunctionDeclSyntaxBuilder(
            declaration: "public static func == (lhs: \(type.trimmed), rhs: \(type.trimmed)) -> Bool"
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
    
    private static func prepareParams(node: AttributeSyntax) -> String {
        let parameters = node
            .adapter
            .findArgument(id: "parameters")?
            .adapter
            .strings()
        
        guard let parameters = parameters else { return "" }
        
        var stringValue = """
        """
        
        for (index, item) in parameters.enumerated() {
            if index == 0 && parameters.count == 1 {
                stringValue.append("lhs.\(item) == rhs.\(item)")
            } else if index == 0 {
                stringValue.append("lhs.\(item) == rhs.\(item) && ")
            } else if index != 0 && item != parameters.last {
                stringValue.append("lhs.\(item) == rhs.\(item) && ")
            } else if index != 0 && item == parameters.last {
                stringValue.append("lhs.\(item) == rhs.\(item)")
            }
        }

        return stringValue
    }
}