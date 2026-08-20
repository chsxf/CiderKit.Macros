import SwiftSyntax

internal typealias MemberBasicInfo = (name: String, type: String, makeOptional: Bool, withDefaultValue: String?, keepValueDuringMutation: Bool)

internal extension VariableDeclSyntax {

    var isVar: Bool { bindingSpecifier.tokenKind == .keyword(.var) }
    var isLet: Bool { bindingSpecifier.tokenKind == .keyword(.let) }

    var isAccessibleLetStoredProperty: Bool {
        isAccessibleStoredProperty && isLet
    }

    var isAccessibleStoredProperty: Bool {
        guard isVar || isLet else {
            return false
        }

        guard modifiers.contains(where: { $0.name.tokenKind == .keyword(.public) || $0.name.tokenKind == .keyword(.internal) }) || modifiers.isEmpty else {
            return false
        }

        if isVar {
            guard let binding = bindings.first, bindings.count == 1 else {
                return false
            }

            switch binding.accessorBlock?.accessors {
                case .none:
                    return true

                case .getter:
                    return false

                case .accessors(let node):
                    for accessor in node {
                        switch accessor.accessorSpecifier.tokenKind {
                            case .keyword(.willSet), .keyword(.didSet):
                                return true

                            default:
                                return false
                        }
                    }
                    return true
            }
        }

        return true
    }

    var memberBasicInfo: MemberBasicInfo? {
        guard
            // Get the property's name (a.k.a. identifier)...
            let patternBinding = bindings.first,
            let name = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier,

            // ...and then the property's type...
            let type = patternBinding.typeAnnotation?.trimmed.description
        else { return nil }

        var index = type.startIndex
        while type[index] == ":" || type[index] == " " {
            index = type.index(after: index)
        }
        let trimmedType = String(type[index...])

        return (name: name.text, type: trimmedType, makeOptional: false, withDefaultValue: nil, keepValueDuringMutation: true)
    }

    func hasAttribute(_ searchedAttributeName: String) -> Bool {
        self.getAttribute(searchedAttributeName) != nil
    }

    func getAttribute(_ searchedAttributeName: String) -> AttributeSyntax? {
        for attributeListChild in attributes {
            switch attributeListChild {
                case .attribute(let attributeSyntax):
                    if attributeSyntax.attributeName.trimmedDescription == searchedAttributeName {
                        return attributeSyntax
                    }

                case .ifConfigDecl:
                    break
            }
        }
        return nil
    }

}
