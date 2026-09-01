import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import CiderKitMacrosCommon

public struct MutableStructMacro: MemberMacro {

    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let structEnclosingType = declaration.as(StructDeclSyntax.self) else {
            throw MacroErrors.notStructType
        }

        var structAccessLevel: AccessLevel = structEnclosingType.accessLevel
        if let initAccessLevelExpr = node.argument(for: "initAccessLevel")?.as(MemberAccessExprSyntax.self) {
            structAccessLevel = try AccessLevel(from: initAccessLevelExpr.declName.trimmedDescription)
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

            if let mutatingAttribute = storedProperty.getAttribute("MutatingProperty") {
                if let propertyAccessLevelExpr = mutatingAttribute.argument(for: "accessLevel")?.as(MemberAccessExprSyntax.self) {
                    memberInfo.accessLevel = try AccessLevel(from: propertyAccessLevelExpr.declName.trimmedDescription)
                }

                mutatingProperties.append(memberInfo)
            }

            allMembersInfo.append(memberInfo)
        }

        allMembersInfo.sort { !$0.makeOptional && $1.makeOptional }

        if let initSyntax = buildInitializer(structEnclosingType: structEnclosingType, membersInfo: allMembersInfo, accessLevel: structAccessLevel) {
            result.append(initSyntax)
        }
        result.append(contentsOf: mutatingProperties.compactMap {
            generateMutatingProperty(structEnclosingType: structEnclosingType, propertyMemberInfo: $0, allMembersInfo: allMembersInfo)
        })

        return result
    }

    fileprivate static func buildInitializer(structEnclosingType: StructDeclSyntax, membersInfo: [MemberBasicInfo], accessLevel: AccessLevel) -> DeclSyntax? {
        let memberNames = membersInfo.map { $0.name }
        guard !structEnclosingType.hasExistingInitializer(withOrderedParameterNames: memberNames) else { return nil }

        let accessLevelStr = accessLevel == .internal ? "" : "\(accessLevel) "

        return """
        \(raw: accessLevelStr)init(
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

    fileprivate static func generateMutatingProperty(structEnclosingType: StructDeclSyntax, propertyMemberInfo: MemberBasicInfo, allMembersInfo: [MemberBasicInfo]) -> DeclSyntax? {
        let propertyMemberName = propertyMemberInfo.name
        let secondCharactetIndex = propertyMemberName.index(propertyMemberName.startIndex, offsetBy: 1)
        let uppercasedMemberName = "\(propertyMemberName.first!.uppercased())\(propertyMemberName[secondCharactetIndex...])"
        let newParameterName = "with\(uppercasedMemberName)"
        let newLocalParameterName = "new\(uppercasedMemberName)"

        guard !structEnclosingType.hasExistingMethod(named: "mutated", withOrderedParameterNames: [newParameterName]) else { return nil }

        let accessLevelStr = propertyMemberInfo.accessLevel == .internal ? "" : "\(propertyMemberInfo.accessLevel) "

        return """
        \(raw: accessLevelStr)func mutated(\(raw: newParameterName) \(raw: newLocalParameterName): \(raw: propertyMemberInfo.type)) -> Self {
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
