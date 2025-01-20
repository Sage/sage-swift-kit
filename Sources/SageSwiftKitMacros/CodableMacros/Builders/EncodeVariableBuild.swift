//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct EncodeVariableBuild {
    let variable: VariableDeclSyntax
    let dateFormatter: String
    
    init(
        variable: VariableDeclSyntax,
        dateFormatter: String
    ) {
        self.variable = variable
        self.dateFormatter = dateFormatter
    }
    
    private var adapter: VariableDeclSyntaxAdapter { variable.adapter }
    
    private var varName: String {
        variable.adapter.identifier.text
    }
    
    func build() -> CodeBlockItemSyntaxBuilder {
        if let attribute = adapter.getAttributeFor(macro: .customDate) {
            return buildCustomDate(attribute: attribute)
        }
        
        return buildBasicDecode()
    }
    
    func buildBasicDecode() -> CodeBlockItemSyntaxBuilder {
        return .init().addLine("try container.encode(\(varName), forKey: .\(varName))")
    }
    
    func buildCustomDate(attribute: AttributeSyntax) -> CodeBlockItemSyntaxBuilder {
        guard let dateFormat = attribute.adapter.findArgument(id: "dateFormat") else {
            return buildBasicDecode()
        }
        
        if adapter.typeAnnotation.type.kind == .optionalType {
            let ifExpr = IfExprSyntaxBuilder(
                condition: "if let \(varName)",
                body: [
                    .init()
                    .addLine(dateFormSetted(format: dateFormat.expression.description))
                    .addLine(buildDateEncode())
                ]
            )
            
            return .init().setBuilder(ifExpr)
        } else {
            return .init()
                .addLine(dateFormSetted(format: dateFormat.expression.description))
                .addLine(buildDateEncode())
        }
    }
    
    private func dateFormSetted(format: String) -> String {
        "\(dateFormatter).dateFormat = \(format)"
    }
    
    private func buildDateEncode() -> String {
        "try container.encode(\(dateFormatter).string(from: \(varName)), forKey: .\(varName))"
    }
}
