//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

struct MockableVariablesBuilder {
    let functionSyntax: FunctionDeclSyntax
    let accessLevel: String
    
    init(
        functionSyntax: FunctionDeclSyntax,
        accessLevel: String
    ) {
        self.functionSyntax = functionSyntax
        self.accessLevel = accessLevel
    }
    
    private var name: String {
        let name = functionSyntax.name.text
        
        let params = allParameters ?? []
        
        return params.reduce(name, { acc, param -> String in
            return acc+"_\(param.firstName.text)"
        })
    }
    
    var callsCountName: String { "\(name)CallsCount" }
    var calledName: String { "\(name)Called" }
    var parametersName: String { "\(name)Parameters" }
    var parametersNameCall: String { "\(name)ParametersCalls" }
    var returnName: String { "\(name)ReturnValue" }
    
    func callsCountVar() throws -> VariableDeclSyntax {
        try .init(
            .init(stringLiteral: "\(accessLevel) var \(callsCountName): Int = 0")
        )
    }
    
    func calledVar() throws -> VariableDeclSyntax {
        try .init(
            .init(stringLiteral: "\(accessLevel) var \(calledName): Bool"),
            accessor: {
                .init(stringLiteral: "\(callsCountName) > 0")
            }
        )
    }
    
    var allParameters: [FunctionParameterSyntax]? {
        guard let clause = functionSyntax.signature.parameterClause.as(FunctionParameterClauseSyntax.self) else {
            return nil
        }
        
        return clause.parameters.compactMap { $0.as(FunctionParameterSyntax.self)
        }
    }
    
    var parametersTupple: String? {
        guard let allParameters else { return nil }
        
        let parameterTupple: (FunctionParameterSyntax) -> String = { (param: FunctionParameterSyntax) -> String in
            let name = param.secondName?.text ?? param.firstName.text
            
            let description = param.type.description.replacingOccurrences(of: "@escaping", with: "")
            
            return "\(name): \(description)"
        }
        
        if allParameters.count == 1 {
            return allParameters[0].type.description
        }
        
        return allParameters.reduce("", { acc, param in
            let variableValue = parameterTupple(param)
            
            if acc.isEmpty {
                return variableValue
            }
            
            return acc+", "+variableValue
        })
    }
    
    func parametersVar() throws -> VariableDeclSyntax? {
        guard let parametersTupple, let allParameters else { return nil }
        
        if allParameters.count == 1 {
            return try .init(
                .init(stringLiteral: "\(accessLevel) var \(parametersName): \(parametersTupple)?"),
                accessor: {
                    .init(stringLiteral: "self.\(parametersNameCall).last")
                }
            )
        }
        
        return try .init(
            .init(stringLiteral: "\(accessLevel) var \(parametersName): (\(parametersTupple))?"),
            accessor: {
                .init(stringLiteral: "self.\(parametersNameCall).last")
            }
        )
    }
    
    func parametersCallsVar() throws -> VariableDeclSyntax? {
        guard let parametersTupple else { return nil }
        
        return try .init(
            .init(stringLiteral: "\(accessLevel) var \(parametersNameCall): [(\(parametersTupple))] = []")
        )
    }
    
    func returnVariable() throws -> VariableDeclSyntax? {
        guard let returnValue = functionSyntax.signature.returnClause else {
            return nil
        }
        
        if returnValue.description.contains("Void") {
            return nil
        }
        
        if returnValue.description.contains("?") {
            return try .init(
                .init(stringLiteral: "\(accessLevel) var \(returnName): \(returnValue.type.description)")
            )
        }
        
        return try .init(
            .init(stringLiteral: "\(accessLevel) var \(returnName): \(returnValue.type.description)!")
        )
    }
}
