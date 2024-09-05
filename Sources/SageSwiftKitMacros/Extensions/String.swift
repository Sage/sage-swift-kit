//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

extension String {
    var tokenSyntax: TokenSyntax {
        .init(stringLiteral: self)
    }
}
