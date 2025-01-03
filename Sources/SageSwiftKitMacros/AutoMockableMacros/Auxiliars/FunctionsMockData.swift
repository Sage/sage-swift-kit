//
// Copyright © 2024 Sage.
// All Rights Reserved.
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

struct ParamsMockData {
    let firstName: TokenSyntax
    let secondName: TokenSyntax?
    let type: TypeSyntaxProtocol
    
    init(firstName: TokenSyntax, secondName: TokenSyntax?, type: TypeSyntaxProtocol) {
        self.firstName = firstName
        self.secondName = secondName
        self.type = type
    }
    
    var name: String { secondName?.text ?? firstName.text }
    
    var noEscapingType: String {
        type.description.replacingOccurrences(of: "@escaping", with: "")
    }
}

struct FunctionsMockData {
    let syntax: FunctionDeclSyntax
    let name: TokenSyntax
    let params: [ParamsMockData]
    let returnType: ReturnClauseSyntax?
    let accessLevel: TokenSyntax
    
    var mocksVarName: String { "mock" }
    
    var needThrows: Bool { syntax.signature.effectSpecifiers?.throwsSpecifier != nil }
    
    init(syntax: FunctionDeclSyntax, accessLevel: TokenSyntax) {
        self.syntax = syntax
        self.name = syntax.name
        self.params = syntax.signature
            .as(FunctionSignatureSyntax.self)?
            .parameterClause.as(FunctionParameterClauseSyntax.self)?
            .parameters.compactMap { param -> ParamsMockData? in
                guard let casted = param.as(FunctionParameterSyntax.self) else {
                    return nil
                }
                
                return .init(
                    firstName: casted.firstName,
                    secondName: casted.secondName,
                    type: casted.type
                )
            } ?? []
        
        self.returnType = syntax.signature.returnClause
        self.accessLevel = accessLevel
    }
}

extension FunctionsMockData {
    var className: String {
        nameToIdentify.prefix(1).uppercased()+nameToIdentify.dropFirst()
    }
    
    var nameToIdentify: String {
        let startPattern = name.text
        
        return params.reduce(startPattern, { acc, param -> String in
            let name = param.name
            
            return acc+"_\(name.prefix(1).uppercased()+param.name.dropFirst())"
        })
    }
    
    var returnValue: String? {
        guard let returnType else {
            return nil
        }
        
        if let optionalType = returnType.type.as(OptionalTypeSyntax.self) {
            return optionalType.description
        }
        
        if let optionalType = returnType.type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return optionalType.description
        }
        
        return ImplicitlyUnwrappedOptionalTypeSyntax(wrappedType: returnType.type).description
    }
}
