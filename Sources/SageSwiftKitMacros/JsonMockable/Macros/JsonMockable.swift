//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum JsonMockable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var declSyntax: [DeclSyntax] = []
        
        var name: String?
        
        if let structSyntax = declaration.as(StructDeclSyntax.self) {
            name = structSyntax.name.text
        } else if let classSyntax = declaration.as(ClassDeclSyntax.self) {
            name = classSyntax.name.text
        }
        
        guard let name else { return declSyntax }
        
        let function = FunctionDeclSyntax(
            modifiers: .init(itemsBuilder: {
                DeclModifierSyntax(name: "private")
                DeclModifierSyntax(name: "static")
            }),
            name: "getMock",
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax(itemsBuilder: {
                        getBundleParamter()
                        getKeyDecodingStrategyParam()
                        getFileNameParam()
                    })
                ),
                effectSpecifiers: FunctionEffectSpecifiersSyntax(
                    throwsSpecifier: "throws".tokenSyntax
                ),
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(name: "Self")
                )
            ),
            body: try CodeBlockSyntax(statementsBuilder: {
                try "let mockURL = bundle.url(forResource: fileName, withExtension: \"json\")".codeBlock
                
                try getDataGuard()
                
                try "let decoder = JSONDecoder()".codeBlock
                try "decoder.keyDecodingStrategy = keyDecodingStrategy".codeBlock
                
                try "return try decoder.decode(\(name).self, from: data)".codeBlock
            })
        )
        
        declSyntax.append(DeclSyntax(function))
                
        let variable = try VariableDeclSyntax(
            "public static var jsonMock: \(name.tokenSyntax)") {
                try .init(itemsBuilder: {
                    try AccessorDeclSyntax(
                        accessorSpecifier: .keyword(.get),
                        effectSpecifiers: AccessorEffectSpecifiersSyntax(throwsSpecifier: "throws".tokenSyntax),
                        bodyBuilder: {
                            if let keyDecodingStrategy = try getKeyDecodingStrategy(node: node) {
                                keyDecodingStrategy
                            }
                            
                            if let bundleValue = try getBundle(node: node) {
                                bundleValue
                            }
                            
                            if let fileName = try getJsonFileName(node: node, name: name) {
                                fileName
                            }
                            
                            try "return try getMock(bundle: bundle, keyDecodingStrategy: keyDecodingStrategy, fileName: fileName)".codeBlock
                        })
                })
            }
        
        declSyntax.append(
            DeclSyntax(variable)
        )
        
        return declSyntax
    }
    
    static func getBundleParamter() -> FunctionParameterSyntax {
        FunctionParameterSyntax(
            firstName: "bundle".tokenSyntax,
            type: IdentifierTypeSyntax(name: "Bundle")
        )
    }
    
    static func getKeyDecodingStrategyParam() -> FunctionParameterSyntax {
        FunctionParameterSyntax(
            firstName: "keyDecodingStrategy".tokenSyntax,
            type: IdentifierTypeSyntax(name: "JSONDecoder.KeyDecodingStrategy")
        )
    }
    
    static func getFileNameParam() -> FunctionParameterSyntax {
        FunctionParameterSyntax(
            firstName: "fileName".tokenSyntax,
            type: IdentifierTypeSyntax(name: "String?")
        )
    }
    
    static func getDataGuard() throws -> GuardStmtSyntax {
        return GuardStmtSyntax(
            guardKeyword: .keyword(.guard),
            conditions: .init(
                itemsBuilder: {
                    ConditionElementSyntax(condition: .expression("let mockURL"))
                    ConditionElementSyntax(condition: .expression("let data = try? Data(contentsOf: mockURL) "))
                }),
            elseKeyword: .keyword(.else),
            bodyBuilder: {
                "throw NSError(domain: \"No data found\", code: 500)"
            }
        )
    }
    
    static func getKeyDecodingStrategy(node: AttributeSyntax) throws -> VariableDeclSyntax? {
        guard let value = node
            .adapter
            .findArgument(id: "keyDecodingStrategy")?
            .adapter
            .expression(cast: MemberAccessExprSyntax.self) else { return nil }
        
        return try VariableDeclSyntax("var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy") {
            .init(itemsBuilder: {
                value
            })
        }
    }
    
    static func getBundle(node: AttributeSyntax) throws -> VariableDeclSyntax? {
        guard let value = node
            .adapter
            .findArgument(id: "bundle")?
            .adapter
            .expression(cast: MemberAccessExprSyntax.self) else { return nil }
        
        return try
        VariableDeclSyntax("var bundle: Bundle") {
            .init(itemsBuilder: {
                value
            })
        }
    }
    
    static func getJsonFileName(node: AttributeSyntax, name: String) throws -> VariableDeclSyntax? {
        let value = node
            .adapter
            .findArgument(id: "jsonFile")?
            .adapter
            .expression(cast: StringLiteralExprSyntax.self)
        
        return try VariableDeclSyntax("var fileName: String") {
            .init(itemsBuilder: {
                if let value {
                    value
                } else {
                    CodeBlockItemSyntax(stringLiteral: "String(describing: \(name).self)")
                }
            })
        }
    }
}
