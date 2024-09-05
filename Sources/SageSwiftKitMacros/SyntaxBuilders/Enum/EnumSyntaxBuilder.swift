//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

class EnumSyntaxBuilder: SyntaxBuilder<EnumDeclSyntax> {
    let declaration: String
    let cases: SyntaxBuilder<MemberBlockSyntax>
    
    init(
        declaration: String,
        cases: CasesEnumSyntaxBuilder
    ) {
        self.declaration = declaration
        self.cases = cases
    }
    
    override func build() throws -> EnumDeclSyntax {
        EnumDeclSyntax(
            name: "\(raw: declaration)",
            memberBlock: try cases.build()
        )
    }
}
