import SwiftSyntax
import SwiftSyntaxMacros

public struct MutatingPropertyMacro: PeerMacro {

    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let storedPropertyDecl = declaration.as(VariableDeclSyntax.self) else {
            throw MacroErrors.notAssociatedWithStoredProperty
        }

        guard storedPropertyDecl.isPublicOrInternal else {
            throw MacroErrors.notPublicOrInternal
        }

        guard storedPropertyDecl.isAccessibleStoredProperty else {
            throw MacroErrors.notAssociatedWithStoredProperty
        }

        return []
    }

}
