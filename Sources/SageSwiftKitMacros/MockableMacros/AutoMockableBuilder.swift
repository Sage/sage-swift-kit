//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum AutoMockable: PeerMacro {
    static var mocksVarName: String { "mock" }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolSyntax = declaration.as(ProtocolDeclSyntax.self) else {
            return []
        }
        
        let accessLevel = node
            .adapter
            .findArgument(id: "accessLevel")?
            .adapter
            .expression(cast: StringLiteralExprSyntax.self)?.representedLiteralValue ?? "internal"
        
        let procotolName = protocolSyntax.name.text
        
        guard let members = declaration.as(ProtocolDeclSyntax.self)?.memberBlock.members else {
            return []
        }
        
        let variablesToMock: [VariableDeclSyntax] = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        let functionsToMock: [FunctionsMockData] = members
            .compactMap { item -> FunctionsMockData? in
                guard let casted = item.decl.as(FunctionDeclSyntax.self) else {
                    return nil
                }
                
                return FunctionsMockData(syntax: casted, accessLevel: accessLevel.tokenSyntax)
            }
        
        return [
            DeclSyntax(
                ClassDeclSyntax(
                    modifiers: .init(itemsBuilder: {
                        DeclModifierSyntax(name: accessLevel.tokenSyntax)
                    }),
                    name: .identifier("\(procotolName)Mock"),
                    inheritanceClause: .init(
                        inheritedTypes: .init(itemsBuilder: {
                            InheritedTypeSyntax(
                                type: IdentifierTypeSyntax(
                                    name: .identifier(procotolName)
                                )
                            )
                            
                            if let inherited = protocolSyntax.inheritanceClause {
                                inherited.inheritedTypes
                            }
                        })
                    ),
                    memberBlock: MemberBlockSyntax(
                        members: try MemberBlockItemListSyntax(itemsBuilder: {
                            // Init
                            InitializerDeclSyntax(
                                modifiers: .init(itemsBuilder: {
                                    DeclModifierSyntax(name: accessLevel.tokenSyntax)
                                }),
                                signature: .init(
                                    parameterClause: .init(
                                        parameters: .init(
                                            itemsBuilder: {}
                                        )
                                    )
                                ),
                                body: .init(
                                    statements: .init(
                                        itemsBuilder: {
                                            
                                        }
                                    )
                                )
                            )
                            
                            // Classes that has mock data for each function
                            for funcData in functionsToMock {
                                ClassMockForFunctionBuilder(funcData: funcData).build()
                            }
                            
                            // Class with all functions mock
                            FunctionMocksClassBuilder(
                                functions: functionsToMock,
                                accessLevel: accessLevel.tokenSyntax
                            ).build()
                            
                            // Variable mocks
                            FunctionMocksClassBuilder(
                                functions: functionsToMock,
                                accessLevel: accessLevel.tokenSyntax
                            ).buildVarForTheClass()
                            
                            // Implementation of each variable
                            for variable in variablesToMock {
                                let varConformance = ProtocolVarsConformanceBuilder(
                                    variable: variable,
                                    accessLevel: accessLevel.tokenSyntax
                                )
                                
                                varConformance.build()
                                varConformance.buildReturnVar()
                            }
                            
                            // Implementation of each function
                            for data in functionsToMock {
                                try ProtocolFunctionsConformanceBuilder(
                                    data: data
                                ).build()
                            }
                        })
                    )
                )
            )
        ]
    }
}
