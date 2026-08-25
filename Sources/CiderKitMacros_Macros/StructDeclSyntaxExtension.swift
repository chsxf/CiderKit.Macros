import SwiftSyntax

internal extension DeclGroupSyntax {

    /// Get the stored properties from the declaration based on syntax.
    func accessibleStoredProperties() -> [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self), variable.isAccessibleStoredProperty else { return nil }
            return variable
        }
    }

    func hasExistingInitializer(withOrderedParameterNames orderedParameterNames: [String]) -> Bool {
        memberBlock.members.contains { member in
            guard let initializer = member.decl.as(InitializerDeclSyntax.self) else { return false }
            return parametersAreMatching(declaredParameters: initializer.signature.parameterClause.parameters, withOrderedParameterNames: orderedParameterNames)
        }
    }

    func hasExistingMethod(named name: String, withOrderedParameterNames orderedParameterNames: [String]) -> Bool {
        memberBlock.members.contains { member in
            guard let function = member.decl.as(FunctionDeclSyntax.self), function.name.trimmedDescription == name else { return false }
            return parametersAreMatching(declaredParameters: function.signature.parameterClause.parameters, withOrderedParameterNames: orderedParameterNames)
        }
    }

    private func parametersAreMatching(declaredParameters: FunctionParameterListSyntax, withOrderedParameterNames orderedParameterNames: [String]) -> Bool {
        guard declaredParameters.count == orderedParameterNames.count else { return false }

        var parameterIndex = declaredParameters.startIndex
        for i in 0..<orderedParameterNames.count {
            if declaredParameters[parameterIndex].firstName.trimmedDescription != orderedParameterNames[i] {
                return false
            }
            parameterIndex = declaredParameters.index(after: parameterIndex)
        }
        return true
    }

}
