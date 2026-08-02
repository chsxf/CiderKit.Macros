import SwiftSyntax

internal extension DeclGroupSyntax {
    
    /// Get the stored properties from the declaration based on syntax.
    func accessibleStoredProperties() -> [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self), variable.isAccessibleStoredProperty else { return nil }
            return variable
        }
    }
    
}
