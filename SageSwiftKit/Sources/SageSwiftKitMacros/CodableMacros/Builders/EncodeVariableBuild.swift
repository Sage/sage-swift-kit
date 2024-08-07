//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct EncodeVariableBuild {
    let variable: VariableDeclSyntax
    
    init(variable: VariableDeclSyntax) {
        self.variable = variable
    }
    
    private var varName: String {
        variable.adapter.identifier.text
    }
    
    func build() -> CodeBlockItemSyntaxBuilder {
        .init(code: "try container.encode(\(varName), forKey: .\(varName))")
    }
}
