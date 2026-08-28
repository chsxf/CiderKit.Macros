import SwiftSyntax
import CiderKitMacrosCommon

internal extension StructDeclSyntax {

    var accessLevel: AccessLevel {
        for modifier in modifiers {
            switch modifier.name.tokenKind {
                case .keyword(.fileprivate):
                    return .fileprivate
                case .keyword(.package):
                    return .package
                case .keyword(.private):
                    return .private
                case .keyword(.public):
                    return .public
                default:
                    break
            }
        }

        return .internal
    }

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
        for orderedParameterIndex in 0..<orderedParameterNames.count {
            if declaredParameters[parameterIndex].firstName.trimmedDescription != orderedParameterNames[orderedParameterIndex] {
                return false
            }
            parameterIndex = declaredParameters.index(after: parameterIndex)
        }
        return true
    }

}
