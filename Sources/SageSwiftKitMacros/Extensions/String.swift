//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

extension String {
    var tokenSyntax: TokenSyntax {
        .init(stringLiteral: self)
    }
    
    var declSyntax: DeclSyntax {
        get throws {
            try .init(validating: "\(raw: self)")
        }
    }
    
    var codeBlock: CodeBlockItemSyntax {
        get throws {
            try .init(validating: "\(raw: self)")
        }
    }
}
