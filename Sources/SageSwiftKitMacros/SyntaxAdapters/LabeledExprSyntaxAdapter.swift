//
// Copyright © 2024 Sage.
// All Rights Reserved.

import Foundation
import SwiftSyntax

extension LabeledExprSyntax {
    var adapter: LabeledExprSyntaxAdapter {
        .init(syntax: self)
    }
}

struct LabeledExprSyntaxAdapter {
    private let syntax: LabeledExprSyntax
    
    init(syntax: LabeledExprSyntax) {
        self.syntax = syntax
    }
     
    var identifier: String {
        syntax.label!.text
    }
    
    func expression<T: ExprSyntaxProtocol>(cast: T.Type) -> T? {
        syntax.expression.as(T.self)
    }
    
    func string() -> String? {
        expression(cast: StringLiteralExprSyntax.self)?
            .segments
            .first?.as(StringSegmentSyntax.self)?
            .content
            .text
    }
    
    func bool() -> Bool? {
        guard let value = expression(cast: BooleanLiteralExprSyntax.self)?
            .literal
            .text else {
            return nil
        }
        
        return Bool(value)
    }
    
    func strings() -> [String] {
        expression(cast: ArrayExprSyntax.self)?
            .elements.as(ArrayElementListSyntax.self)?
            .compactMap { $0.as(ArrayElementSyntax.self) }
            .compactMap { $0.expression.as(StringLiteralExprSyntax.self) }
            .compactMap { $0.segments.as(StringLiteralSegmentListSyntax.self) }
            .compactMap { $0.first?.as(StringSegmentSyntax.self) }
            .map { $0.content.text } ?? []
    }
}
