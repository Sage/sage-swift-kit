//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum AutoMockable: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var declarations: [DeclSyntax] = []
        
        let accessLevel = node
            .adapter
            .findArgument(id: "accessLevel")?
            .adapter
            .string() ?? ""
        
        guard let protocolSyntax = declaration.as(ProtocolDeclSyntax.self) else {
            return declarations
        }
        
        let functions = self.getProtocolFunctions(declaration: protocolSyntax)
        
        let procotolName = protocolSyntax.name.text
        
        let mockClass = ClassDeclSyntaxBuilder(
            declaration: "\(accessLevel) class \(procotolName)Mock: \(procotolName)"
        )
        
        do {
            mockClass.bodyItems.append(
                try InitializerDeclSyntax(
                    .init(stringLiteral: "\(accessLevel) init()"),
                    bodyBuilder: {}
                )
            )
            
            for protocolFunction in functions {
                let varsBuilder = MockableVariablesBuilder(
                    functionSyntax: protocolFunction,
                    accessLevel: accessLevel
                )
                
                mockClass.appendItem(item: try varsBuilder.callsCountVar())
                mockClass.appendItem(item: try varsBuilder.calledVar())
                
                if let parameters = try varsBuilder.parametersVar() {
                    mockClass.appendItem(item: parameters)
                }
                
                if let variableSybtax = try varsBuilder.parametersCallsVar() {
                    mockClass.appendItem(item: variableSybtax)
                }
                
                if let returnVariable = try varsBuilder.returnVariable(){
                    mockClass.appendItem(item: returnVariable)
                }
            }
            
            for protocolFunction in functions {
                let builder = MockableFunctionBuilder(
                    functionSyntax: protocolFunction,
                    accessLevel: accessLevel
                )
                
                mockClass.appendItem(item: try builder.build())
            }
        } catch {
            context.addDiagnostics(from: error, node: node)
        }
        
        declarations.append(DeclSyntax(try mockClass.build()))
        
        return declarations
    }
    
    private static func getProtocolFunctions(declaration: ProtocolDeclSyntax) -> [FunctionDeclSyntax] {
        return declaration.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}
