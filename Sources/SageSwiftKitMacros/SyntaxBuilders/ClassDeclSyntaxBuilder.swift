//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

class ClassDeclSyntaxBuilder: SyntaxBuilder<ClassDeclSyntax> {
    let declaration: String
    var bodyItems: [DeclSyntaxProtocol]
    
    init(declaration: String, bodyItems: [DeclSyntaxProtocol] = []) {
        self.declaration = declaration
        self.bodyItems = bodyItems
    }
    
    func appendItem(item: DeclSyntaxProtocol) {
        bodyItems.append(item)
    }
    
    override func build() throws -> ClassDeclSyntax {
        return try ClassDeclSyntax(
            .init(stringLiteral: declaration),
            membersBuilder: {
                for item in bodyItems {
                    item
                }
            }
        )
    }
}
