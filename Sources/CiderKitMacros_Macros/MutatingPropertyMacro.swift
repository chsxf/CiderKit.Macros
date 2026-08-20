import SwiftSyntax
import SwiftSyntaxMacros

public struct MutatingPropertyMacro: PeerMacro {

    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let storedPropertyDecl = declaration.as(VariableDeclSyntax.self), storedPropertyDecl.isAccessibleStoredProperty else {
            throw MacroErrors.notAssociatedWithLetStoredProperty
        }

        if !storedPropertyDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) || $0.name.tokenKind == .keyword(.internal) }) {
            throw MacroErrors.notPublicOrInternal
        }

        return []
    }

}
