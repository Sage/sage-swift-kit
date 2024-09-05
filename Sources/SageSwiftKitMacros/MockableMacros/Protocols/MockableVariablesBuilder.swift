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
    
    private var name: String { functionSyntax.name.text }
    
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
    
    var parametersTupple: String? {
        guard let clause = functionSyntax.signature.parameterClause.as(FunctionParameterClauseSyntax.self) else {
            return nil
        }
        
        let allParameters: [FunctionParameterSyntax] = clause.parameters.compactMap { $0.as(FunctionParameterSyntax.self) }
        
        var parameterTupple: (FunctionParameterSyntax) -> String = { (param: FunctionParameterSyntax) -> String in
            let name = param.secondName?.text ?? param.firstName.text
            
            if var attributed = param.type.as(AttributedTypeSyntax.self) {
                attributed.attributes = .init(stringLiteral: "")
                return "\(name): \(attributed.description)"
            }
            
            if var identifier = param.type.as(IdentifierTypeSyntax.self) {
                return "\(name): \(identifier.description)"
            }
            
            return "\(name): \(param.description)"
        }
        
        if allParameters.count == 1 {
            return parameterTupple(allParameters[0])
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
        guard let parametersTupple else { return nil }
        
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
        guard let returnValue = functionSyntax.signature.returnClause,
              let type = returnValue.type.as(IdentifierTypeSyntax.self) else { 
            return nil
        }
        
        if type.name.text == "Void" {
            return nil
        }
        
        return try .init(
            .init(stringLiteral: "\(accessLevel) var \(returnName): \(type.description)!")
        )
    }
}
