import SwiftSyntax

extension AttributeSyntax {
    func argument(for label: String) -> ExprSyntax? {
        arguments?.as(LabeledExprListSyntax.self)?.filter({ $0.label?.text == label }).first?.expression
    }
}
