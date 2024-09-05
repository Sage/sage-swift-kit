//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

struct MockableFunctionBuilder {
    let functionSyntax: FunctionDeclSyntax
    let variables: MockableVariablesBuilder
    let accessLevel: String
    
    init(
        functionSyntax: FunctionDeclSyntax,
        accessLevel: String
    ) {
        self.functionSyntax = functionSyntax
        self.variables = MockableVariablesBuilder(functionSyntax: functionSyntax, accessLevel: accessLevel)
        self.accessLevel = accessLevel
    }
    
    func build() throws -> FunctionDeclSyntax {
        try .init(
            .init(stringLiteral: "\(accessLevel) \(functionSyntax.description)"),
            bodyBuilder: {
                calledIncrease
                argumentsRegistration
                
                if let item = try returnItem() {
                    item
                }
            })
    }
    
    private var calledIncrease: CodeBlockItemSyntax {
        let varName = variables.callsCountName
        
        return .init(stringLiteral: "self.\(varName) += 1")
    }
    
    private var variablesName: [String] {
        guard let params = functionSyntax.signature.parameterClause.as(FunctionParameterClauseSyntax.self)?.parameters else {
            return []
        }
        
        var names: [String] = []
        
        for parameter in params {
            names.append(parameter.secondName?.text ?? parameter.firstName.text)
        }
        
        return  names
    }
    
    private var argumentsRegistration: CodeBlockItemSyntax {
        let varName = variables.parametersNameCall
        
        let callVariables: String = variablesName.reduce("", { acc, name in
            let callVariable = "\(name):\(name)"
            
            if acc.isEmpty {
                return callVariable
            } else {
                return acc+", "+callVariable
            }
        })
        
        return .init(stringLiteral: "self.\(varName).append((\(callVariables)))")
    }
    
    private func returnItem() throws -> CodeBlockItemSyntax? {
        if try variables.returnVariable() == nil { return nil }
        
        return .init(
            stringLiteral: "return self.\(variables.returnName)"
        )
    }
}
