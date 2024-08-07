//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

struct CodingKeysBuilder {
    private let nestedKey: String?
    private let variables: [VariableDeclSyntax]
    
    init(
        nestedKey: String?,
        variables: [VariableDeclSyntax]
    ) {
        self.nestedKey = nestedKey
        self.variables = variables
    }
    
    private func buildCases(variables: [VariableDeclSyntax]) -> [CaseEnum] {
        variables.map { variable -> CaseEnum in
                .init(
                    value: variable.adapter.identifier.text,
                    rawValue: variable
                        .adapter
                        .findAttribute(name: String(describing: CustomCodableKey.self))?
                        .adapter
                        .findArgument(id: "name")?
                        .adapter
                        .string()
                )
        }
    }
    
    func buildNestedCodingKeys() -> EnumSyntaxBuilder? {
        guard let nestedKey else { return nil }
        
        return .init(
            declaration: "NestedCodingKeys: String, CodingKey",
            cases: .init(cases: [nestedKey.caseEnum])
        )
    }
    
    func buildCodingKeys() -> EnumSyntaxBuilder {
        .init(
            declaration: "CodingKeys: String, CodingKey",
            cases: .init(cases: buildCases(variables: variables))
        )
    }
}
