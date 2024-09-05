//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

enum DecodingAttribute: Identifiable, Equatable {
    case defaultValue(AttributeSyntax)
    case date(AttributeSyntax)
    case url(AttributeSyntax)
    case stringOrInt(AttributeSyntax)
    case stringToDouble(AttributeSyntax)
    
    var id: String {
        switch self {
        case .defaultValue:
            return String(describing: CustomDefault.self)
        case .date:
            return String(describing: CustomDate.self)
        case .url:
            return String(describing: CustomURL.self)
        case .stringOrInt:
            return String(describing: StringOrInt.self)
        case .stringToDouble:
            return String(describing: StringToDouble.self)
        }
    }
    
    var attribute: AttributeSyntax {
        switch self {
        case .defaultValue(let attributeSyntax):
            return attributeSyntax
        case .date(let attributeSyntax):
            return attributeSyntax
        case .url(let attributeSyntax):
            return attributeSyntax
        case .stringOrInt(let attributeSyntax):
            return attributeSyntax
        case .stringToDouble(let attributeSyntax):
            return attributeSyntax
        }
    }
}

extension Array where Element == DecodingAttribute {
    func getAttribute(macro: PeerMacro.Type) -> DecodingAttribute? {
        self.first(where: { $0.id == String(describing: macro) })
    }
}

struct DecodeVariableBuild {
    let variable: VariableDeclSyntax
    
    init(variable: VariableDeclSyntax) {
        self.variable = variable
    }
    
    private var varName: String {
        variable.adapter.identifier.text
    }
    
    private var type: String {
        variable.adapter.typeAnnotation.type.description
    }
    
    private var kind: SyntaxKind {
        variable.adapter.typeAnnotation.type.kind
    }
    
    private var variableDecodingAttributes: [DecodingAttribute] {
        variable.adapter.attributes.compactMap { variableAttribute -> DecodingAttribute? in
            if variableAttribute.adapter.name == String(describing: CustomDefault.self) {
                return .defaultValue(variableAttribute)
            }
            
            if variableAttribute.adapter.name == String(describing: CustomDate.self) {
                return .date(variableAttribute)
            }
            
            if variableAttribute.adapter.name == String(describing: CustomURL.self) {
                return .url(variableAttribute)
            }
            
            if variableAttribute.adapter.name == String(describing: StringOrInt.self) {
                return .stringOrInt(variableAttribute)
            }
            
            if variableAttribute.adapter.name == String(describing: StringToDouble.self) {
                return .stringToDouble(variableAttribute)
            }
            
            return nil
        }
    }
    
    func build() -> CodeBlockItemSyntaxBuilder {
        if let attribute = variableDecodingAttributes.getAttribute(macro: CustomDate.self)?.attribute {
            return buildCustomDate(attribute: attribute)
        }
        
        if let attribute = variableDecodingAttributes.getAttribute(macro: CustomDefault.self)?.attribute {
            return buildCustomDefault(attribute: attribute)
        }
        
        if let attribute = variableDecodingAttributes.getAttribute(macro: CustomURL.self)?.attribute {
            return buildCustomURL(attribute: attribute)
        }

        if let attribute = variableDecodingAttributes.getAttribute(macro: StringOrInt.self)?.attribute {
            return buildStringOrInt(attribute: attribute)
        }
        
        if let attribute = variableDecodingAttributes.getAttribute(macro: StringToDouble.self)?.attribute {
            return buildStringToDouble(attribute: attribute)
        }
        
        return buildBasicDecode()
    }
    
    func buildBasicDecode() -> CodeBlockItemSyntaxBuilder {
        let optional = kind == .optionalType
        return optional ?
            .init(code: "self.\(varName) = try container.decodeIfPresent(\(type.dropLast()).self, forKey: .\(varName))") :
            .init(code: "self.\(varName) = try container.decode(\(type).self, forKey: .\(varName))")
    }
    
    func buildCustomDate(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard let dateFormat = attribute.adapter.findArgument(id: "dateFormat") else {
            return buildBasicDecode()
        }
        let defaultValue = attribute.adapter.findArgument(id: "defaultValue")
        let conditionalName = "tmp"+varName.capitalized
        
        var elseBody: [CodeBlockItemSyntaxBuilder]?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var body: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "let dateFormatter = DateFormatter()"),
            .init(code: "dateFormatter.dateFormat = \(dateFormat.expression.description)"),
            .init(code: "let date = dateFormatter.date(from: \(conditionalName))")
        ]
        
        if let defaultValue {
            body.append(.init(code: "self.\(varName) = date ?? \(defaultValue.expression.description)"))
            elseBody = [
                .init(code: "self.\(varName) = \(defaultValue.expression.description)")
            ]
        } else {
            body.append(.init(code: "self.\(varName) = date"))
        }
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(String.self, forKey: .\(varName))",
            body: body,
            elseBody: elseBody
        )
        
        return .init(otherBuilder: ifBuilder)
    }
    
    func buildCustomDefault(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard let defaultValue = attribute.adapter.findArgument(id: "defaultValue") else {
            return buildBasicDecode()
        }
        
        let value: String = defaultValue.expression.description
        
        return .init(code: "self.\(varName) = try container.decodeIfPresent(\(type).self, forKey: .\(varName)) ?? \(value)")
    }
    
    func buildStringOrInt(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard type == "String" else {
            return buildBasicDecode()
        }
          
        let conditionalName = "tmp"+varName.capitalized
        
        let ifBody: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "\(varName) = \(conditionalName)")
        ]
        
        let elseIfBody: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "\(varName) = String(\(conditionalName))")
        ]
        
        let elseBody: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "\(varName) = nil")
        ]
     
        let elseIfBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(Int.self, forKey: .\(varName))",
            body: elseIfBody,
            elseBody: elseBody
        )
        let elseIfCode = CodeBlockItemSyntaxBuilder.init(otherBuilder: elseIfBuilder)
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(String.self, forKey: .\(varName))",
            body: ifBody,
            elseBody: [elseIfCode]
        )
        
        return .init(otherBuilder: ifBuilder)
    }
    
    func buildStringToDouble(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        
        guard type == "Double" else {
            return buildBasicDecode()
        }
        
        let conditionalName = "tmp"+varName.capitalized
        
        let ifBody: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "\(varName) = Double(\(conditionalName)) ?? 0")
        ]
        
        let elseBody: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "\(varName) = 0")
        ]
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let \(conditionalName) = try? container.decode(String.self, forKey: .\(varName))",
            body: ifBody,
            elseBody: elseBody
        )
        
        return .init(otherBuilder: ifBuilder)
    }
    
    func buildCustomURL(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
                
        let body: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "self.\(varName) = URL(string: urlString)")
        ]
        
        let elseBody: [CodeBlockItemSyntaxBuilder] = [
            .init(code: "self.\(varName) = nil")
        ]
        
        let ifBuilder = IfExprSyntaxBuilder(
            condition: "if let urlString = try container.decodeIfPresent(String.self, forKey: .\(varName))",
            body: body,
            elseBody: elseBody
        )
        
        return .init(otherBuilder: ifBuilder)
    }
}
