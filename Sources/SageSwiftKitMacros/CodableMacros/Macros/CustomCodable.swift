//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum CustomCodable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var syntax: [DeclSyntax] = []
        
        let nestedKey = node
            .adapter
            .findArgument(id: "nestedProperty")?
            .adapter
            .string()
        
        let variables: [VariableDeclSyntax] = declaration.adapter.variables
        
        let codingKeysBuilder: CodingKeysBuilder = .init(
            nestedKey: nestedKey,
            variables: variables
        )
        
        let decoderInitBuilder = DecoderInitBuilder(
            nestedKey: nestedKey,
            vars: variables
        )
        
        let encoderInitBuilder = EncoderInitBuilder(
            vars: variables
        )
        
        if let nestedKeys = try? codingKeysBuilder.buildNestedCodingKeys()?.build() {
            syntax.append(DeclSyntax(nestedKeys))
        }
        
        if let codingKeys = try? codingKeysBuilder.buildCodingKeys().build() {
            syntax.append(DeclSyntax(codingKeys))
        }
        
        do {
            let initDecoder = try decoderInitBuilder.build()
            syntax.append(DeclSyntax(initDecoder))
            let initEncoder = try encoderInitBuilder.build()
            syntax.append(DeclSyntax(initEncoder))
        } catch {
            context.addDiagnostics(from: error, node: node)
        }
        
        return syntax
    }
}
