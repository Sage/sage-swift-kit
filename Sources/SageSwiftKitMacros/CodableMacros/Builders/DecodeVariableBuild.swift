//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct DecodeVariableBuild {
    let variable: VariableDeclSyntax
    let dateFormatter: String
    
    init(variable: VariableDeclSyntax, dateFormatter: String) {
        self.variable = variable
        self.dateFormatter = dateFormatter
    }
    
    private var adapter: VariableDeclSyntaxAdapter { variable.adapter }
    
    private var varName: String {
        variable.adapter.identifier.text
    }
    
    private var type: String {
        variable.adapter.typeAnnotation.type.description
    }
    
    private var kind: SyntaxKind {
        variable.adapter.typeAnnotation.type.kind
    }
    
    func build() -> CodeBlockItemSyntaxBuilder {
        if let attribute = adapter.getAttributeFor(macro: .customDate) {
            return buildCustomDate(attribute: attribute)
        }
        
        if let attribute = adapter.getAttributeFor(macro: .customDefault) {
            return buildCustomDefault(attribute: attribute)
        }
        
        if let attribute = adapter.getAttributeFor(macro: .customURL) {
            return buildCustomURL(attribute: attribute)
        }

        if let attribute = adapter.getAttributeFor(macro: .stringOrInt) {
            return buildStringOrInt(attribute: attribute)
        }
        
        if let attribute = adapter.getAttributeFor(macro: .stringOrDouble) {
            return buildStringOrDouble(attribute: attribute)
        }
        
        if let attribute = adapter.getAttributeFor(macro: .stringToDouble) {
            return buildStringToDouble(attribute: attribute)
        }
        
        return buildBasicDecode()
    }
    
    func buildBasicDecode() -> CodeBlockItemSyntaxBuilder {
        let optional = kind == .optionalType
        return optional ?
            .code("self.\(varName) = try container.decodeIfPresent(\(type.dropLast()).self, forKey: .\(varName))") :
            .code("self.\(varName) = try container.decode(\(type).self, forKey: .\(varName))")
    }
    
    func buildCustomDate(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard let dateFormat = attribute.adapter.findArgument(id: "dateFormat") else {
            return buildBasicDecode()
        }
        let defaultValue = attribute.adapter.findArgument(id: "defaultValue")
        let conditionalName = "tmp"+varName.capitalized
        
        var elseBody: [CodeBlockItemSyntaxBuilder]?
        
        var body: [CodeBlockItemSyntaxBuilder] = [
            .code("\(dateFormatter).dateFormat = \(dateFormat.expression.description)"),
            .code("let date = \(dateFormatter).date(from: \(conditionalName))")
        ]
        
        if let defaultValue {
            body.append(.code("self.\(varName) = date ?? \(defaultValue.expression.description)"))
            elseBody = [
                .code("self.\(varName) = \(defaultValue.expression.description)")
            ]
        } else {
            body.append(.code("self.\(varName) = date"))
        }
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(String.self, forKey: .\(varName))",
            body: body,
            elseBody: elseBody
        )
        
        return .builder(ifBuilder)
    }
    
    func buildCustomDefault(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard let defaultValue = attribute.adapter.findArgument(id: "defaultValue") else {
            return buildBasicDecode()
        }
        
        let value: String = defaultValue.expression.description
        
        return .code("self.\(varName) = try container.decodeIfPresent(\(type).self, forKey: .\(varName)) ?? \(value)")
    }
    
    func buildStringOrInt(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard type == "String?" else {
            return buildBasicDecode()
        }
          
        let conditionalName = "tmp"+varName.capitalized
        
        let ifBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = \(conditionalName)")
        ]
        
        let elseIfBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = String(\(conditionalName))")
        ]
        
        let elseBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = nil")
        ]
     
        let elseIfBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(Int.self, forKey: .\(varName))",
            body: elseIfBody,
            elseBody: elseBody
        )
        let elseIfCode = CodeBlockItemSyntaxBuilder.builder( elseIfBuilder)
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(String.self, forKey: .\(varName))",
            body: ifBody,
            elseBody: [elseIfCode]
        )
        
        return .builder( ifBuilder)
    }
    
    func buildStringOrDouble(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard type == "String?" else {
            return buildBasicDecode()
        }
        
        let conditionalName = "tmp"+varName.capitalized
        
        let ifBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = \(conditionalName)")
        ]
        
        let elseIfBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = String(\(conditionalName))")
        ]
        
        let elseBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = nil")
        ]
        
        let elseIfBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(Double.self, forKey: .\(varName))",
            body: elseIfBody,
            elseBody: elseBody
        )
        let elseIfCode = CodeBlockItemSyntaxBuilder.builder( elseIfBuilder)
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(String.self, forKey: .\(varName))",
            body: ifBody,
            elseBody: [elseIfCode]
        )
        
        return .builder( ifBuilder)
    }
    
    func buildStringToDouble(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        
        guard type == "Double" else {
            return buildBasicDecode()
        }
        
        let conditionalName = "tmp"+varName.capitalized
        
        let ifBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = Double(\(conditionalName)) ?? 0")
        ]
        
        let elseBody: [CodeBlockItemSyntaxBuilder] = [
            .code("\(varName) = 0")
        ]
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(String.self, forKey: .\(varName))",
            body: ifBody,
            elseBody: elseBody
        )
        
        return .builder( ifBuilder)
    }
    
    func buildCustomURL(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
                
        let body: [CodeBlockItemSyntaxBuilder] = [
            .code("self.\(varName) = URL(string: urlString)")
        ]
        
        let elseBody: [CodeBlockItemSyntaxBuilder] = [
            .code("self.\(varName) = nil")
        ]
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let urlString = try container.decodeIfPresent(String.self, forKey: .\(varName))",
            body: body,
            elseBody: elseBody
        )
        
        return .builder( ifBuilder)
    }
}
