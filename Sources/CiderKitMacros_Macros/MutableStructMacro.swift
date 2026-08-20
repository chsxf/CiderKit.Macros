import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MutableStructMacro: MemberMacro {

    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structEnclosingType = declaration.as(StructDeclSyntax.self) else {
            throw MacroErrors.notStructType
        }

        let accessibleStoredProperties = structEnclosingType.accessibleStoredProperties()

        let mutatingPropertyCount = accessibleStoredProperties.count { $0.hasAttribute("MutatingProperty") }
        if mutatingPropertyCount == 0 {
            return []
        }

        var allMembersInfo = [MemberBasicInfo]()
        var mutatingProperties = [MemberBasicInfo]()

        var result = [DeclSyntax]()

        for storedProperty in accessibleStoredProperties {
            guard var memberInfo = storedProperty.memberBasicInfo else { continue }

            if let attribute = storedProperty.getAttribute("MutableStructOptional") {
                memberInfo.makeOptional = true

                if let stringLiteral = attribute.argument(for: "defaultValue")?.as(StringLiteralExprSyntax.self) {
                    memberInfo.withDefaultValue = stringLiteral.representedLiteralValue
                }

                if let keepValueLiteral = attribute.argument(for: "keepValueDuringMutation")?.as(BooleanLiteralExprSyntax.self), keepValueLiteral.literal.tokenKind == .keyword(.false) {
                    memberInfo.keepValueDuringMutation = false
                }
            }

            if storedProperty.hasAttribute("MutatingProperty") {
                mutatingProperties.append(memberInfo)
            }

            allMembersInfo.append(memberInfo)
        }

        allMembersInfo.sort { !$0.makeOptional && $1.makeOptional }

        result.append(buildInitializer(allMembersInfo))
        result.append(contentsOf: mutatingProperties.map { generateMutatingProperty($0, allMembersInfo: allMembersInfo) })

        return result
    }

    fileprivate static func buildInitializer(_ membersInfo: [MemberBasicInfo]) -> DeclSyntax {
        return """
        public init(
            \(raw: membersInfo.map {
                var result = "\($0.name): \($0.type)"
                if $0.makeOptional {
                    result += "? = nil"
                }
                return result
            }.joined(separator: ",\n"))
        ) {
            \(raw: membersInfo.map { memberInfo in
                if memberInfo.makeOptional {
                    return "self.\(memberInfo.name) = \(memberInfo.name) ?? \(memberInfo.withDefaultValue ?? "nil")"
                } else {
                    return "self.\(memberInfo.name) = \(memberInfo.name)"
                }
            }.joined(separator: "\n"))
        }
        """
    }

    fileprivate static func generateMutatingProperty(_ propertyMemberInfo: MemberBasicInfo, allMembersInfo: [MemberBasicInfo]) -> DeclSyntax {
        let propertyMemberName = propertyMemberInfo.name
        let secondCharactetIndex = propertyMemberName.index(propertyMemberName.startIndex, offsetBy: 1)
        let uppercasedMemberName = "\(propertyMemberName.first!.uppercased())\(propertyMemberName[secondCharactetIndex...])"
        let newParameterName = "with\(uppercasedMemberName)"
        let newLocalParameterName = "new\(uppercasedMemberName)"

        return """
        public func mutated(\(raw: newParameterName) \(raw: newLocalParameterName): \(raw: propertyMemberInfo.type)) -> Self {
            .init(\(raw: allMembersInfo.compactMap { memberInfo in
                if memberInfo.name == propertyMemberName {
                    "\(memberInfo.name): \(newLocalParameterName)"
                } else if memberInfo.makeOptional && !memberInfo.keepValueDuringMutation {
                    nil
                } else {
                    "\(memberInfo.name): \(memberInfo.name)"
                }
            }.joined(separator: ", ")))
        }
        """
    }

}
