//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

extension String {
    var caseEnum: CaseEnum {
        .init(value: self)
    }
}

struct CaseEnum {
    let value: String
    let rawValue: String?
    
    init(value: String, rawValue: String? = nil) {
        self.value = value
        self.rawValue = rawValue
    }
}

class CasesEnumSyntaxBuilder: SyntaxBuilder<MemberBlockSyntax> {
    let cases: [CaseEnum]
    
    init(cases: [CaseEnum]) {
        self.cases = cases
    }
    
    private func enumSyntax(caseEnum: CaseEnum) -> EnumCaseDeclSyntax {
        .init(elements: EnumCaseElementListSyntax(itemsBuilder: {
            .init(
                name: caseEnum.value.tokenSyntax,
                rawValue: enumRawValue(caseEnum: caseEnum)
            )
        }))
    }
    
    private func enumRawValue(caseEnum: CaseEnum) -> InitializerClauseSyntax? {
        guard let rawValue = caseEnum.rawValue else { return nil }
        
        return .init(value: StringLiteralExprSyntax(content: rawValue))
    }
    
    override func build() -> MemberBlockSyntax {
        .init(members: MemberBlockItemListSyntax(itemsBuilder: {
            for enumCase in self.cases {
                enumSyntax(caseEnum: enumCase)
            }
        }))
    }
}
