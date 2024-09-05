//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

extension DeclGroupSyntax {
    var adapter: DeclGroupSyntaxAdapter {
        return .init(syntax: self)
    }
}
 
struct DeclGroupSyntaxAdapter {
    let syntax: DeclGroupSyntax
    
    init(syntax: DeclGroupSyntax) {
        self.syntax = syntax
    }
    
    var variables: [VariableDeclSyntax] {
        syntax.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }
    
    var functions: [FunctionDeclSyntax] {
        syntax.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}
