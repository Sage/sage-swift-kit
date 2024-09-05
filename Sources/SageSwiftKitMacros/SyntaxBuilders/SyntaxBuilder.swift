//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

class SyntaxBuilder<Syntax: SyntaxProtocol> {
    func build() throws -> Syntax {
        return TokenSyntax(stringLiteral: "") as! Syntax
    }
}
