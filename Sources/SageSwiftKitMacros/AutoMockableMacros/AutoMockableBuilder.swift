//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum AutoMockable: PeerMacro {
    static var mocksVarName: String { "mock" }

    static func genericParameterClause(
        for primaryAssociatedTypeClause: PrimaryAssociatedTypeClauseSyntax?,
        members: MemberBlockItemListSyntax
    ) -> GenericParameterClauseSyntax? {
        guard let primaryAssociatedTypeClause else {
            return nil
        }

        let associatedTypeConstraints = Dictionary(
            uniqueKeysWithValues: members.compactMap { item -> (String, InheritanceClauseSyntax)? in
                guard let associatedType = item.decl.as(AssociatedTypeDeclSyntax.self),
                      let inheritanceClause = associatedType.inheritanceClause else {
                    return nil
                }

                return (associatedType.name.text, inheritanceClause)
            }
        )

        return GenericParameterClauseSyntax(
            leftAngle: primaryAssociatedTypeClause.leftAngle,
            parameters: .init(itemsBuilder: {
                for parameter in primaryAssociatedTypeClause.primaryAssociatedTypes {
                    let inheritanceClause = associatedTypeConstraints[parameter.name.text]

                    GenericParameterSyntax(
                        name: parameter.name,
                        colon: inheritanceClause == nil ? nil : .colonToken(),
                        inheritedType: inheritanceClause?.inheritedTypes.first?.type,
                        trailingComma: parameter.trailingComma
                    )
                }
            }),
            rightAngle: primaryAssociatedTypeClause.rightAngle
        )
    }
    
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
        
        let classInheritance = node
            .adapter
            .findArgument(id: "classInheritance")?
            .adapter
            .expression(cast: BooleanLiteralExprSyntax.self)?.literal.text ?? "false"

        guard let members = declaration.as(ProtocolDeclSyntax.self)?.memberBlock.members else {
            return []
        }
        
        let procotolName = protocolSyntax.name.text
        let primaryAssociatedTypeClause = protocolSyntax.primaryAssociatedTypeClause
        let genericParameterClause = genericParameterClause(for: primaryAssociatedTypeClause, members: members)
        let protocolConformanceType = TypeSyntax(
            stringLiteral: procotolName + (primaryAssociatedTypeClause?.trimmedDescription ?? "")
        )
        
        let variablesToMock: [VariableDeclSyntax] = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        let functionsToMock: [FunctionsMockData] = members
            .compactMap { item -> FunctionsMockData? in
                guard let casted = item.decl.as(FunctionDeclSyntax.self) else {
                    return nil
                }

                return FunctionsMockData(syntax: casted, accessLevel: accessLevel.tokenSyntax)
            }
        
        let inheritedTypes = protocolSyntax.inheritanceClause?.inheritedTypes ?? []
        let containsSendable = inheritedTypes.contains { type in
            type.type.trimmedDescription == "Sendable"
        }
        let isActor = inheritedTypes.contains { type in
            type.type.trimmedDescription == "Actor"
        }
        
        let filteredInheritedTypes = inheritedTypes.filter {
            $0.type.trimmedDescription != "Sendable"
        }

        let inheritedTypesForMock = containsSendable ? filteredInheritedTypes : inheritedTypes
        
        let inheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: .init(itemsBuilder: {
                if classInheritance == "true" {
                    for inheritedType in inheritedTypesForMock {
                        inheritedType
                    }
                }

                InheritedTypeSyntax(type: protocolConformanceType)

                if classInheritance == "false" {
                    for inheritedType in inheritedTypesForMock {
                        inheritedType
                    }
                }

                if containsSendable {
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(
                            name: .identifier("@unchecked Sendable")
                        )
                    )
                }
            })
        )

        let memberBlock = MemberBlockSyntax(
            members: try MemberBlockItemListSyntax(itemsBuilder: {
                if classInheritance == "false" {
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
                                itemsBuilder: {}
                            )
                        )
                    )
                }

                for funcData in functionsToMock {
                    ClassMockForFunctionBuilder(funcData: funcData).build()
                }

                FunctionMocksClassBuilder(
                    functions: functionsToMock,
                    accessLevel: accessLevel.tokenSyntax
                ).build()

                FunctionMocksClassBuilder(
                    functions: functionsToMock,
                    accessLevel: accessLevel.tokenSyntax
                ).buildVarForTheClass()

                for variable in variablesToMock {
                    let varConformance = ProtocolVarsConformanceBuilder(
                        variable: variable,
                        accessLevel: accessLevel.tokenSyntax
                    )

                    varConformance.buildReturnVar()
                    varConformance.build()
                }

                for data in functionsToMock {
                    try ProtocolFunctionsConformanceBuilder(
                        data: data
                    ).build()
                }
            })
        )

        if isActor {
            return [
                DeclSyntax(
                    ActorDeclSyntax(
                        modifiers: .init(itemsBuilder: {
                            DeclModifierSyntax(name: accessLevel.tokenSyntax)
                        }),
                        name: .identifier("\(procotolName)Mock"),
                        genericParameterClause: genericParameterClause,
                        inheritanceClause: inheritanceClause,
                        genericWhereClause: protocolSyntax.genericWhereClause,
                        memberBlock: memberBlock
                    )
                )
            ]
        }

        return [
            DeclSyntax(
                ClassDeclSyntax(
                    modifiers: .init(itemsBuilder: {
                        DeclModifierSyntax(name: accessLevel.tokenSyntax)
                        DeclModifierSyntax(name: .keyword(.final))
                    }),
                    name: .identifier("\(procotolName)Mock"),
                    genericParameterClause: genericParameterClause,
                    inheritanceClause: inheritanceClause,
                    genericWhereClause: protocolSyntax.genericWhereClause,
                    memberBlock: memberBlock
                )
            )
        ]
    }
}
