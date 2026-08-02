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
        let membersInfo = accessibleStoredProperties.compactMap { $0.memberBasicInfo }
        
        var result = [DeclSyntax]()
        result.append(buildInitializer(membersInfo))
        
        for storedProperty in accessibleStoredProperties {
            if storedProperty.hasAttribute("MutatingProperty"), let mutatingPropertyDecl = generateMutatingProperty(storedProperty, allMembersInfo: membersInfo) {
                result.append(mutatingPropertyDecl)
            }
        }
        
        return result
    }
    
    fileprivate static func buildInitializer(_ membersInfo: [MemberBasicInfo]) -> DeclSyntax {
        return """
        public init(
            \(raw: membersInfo.map { "\($0.name): \($0.type)" }.joined(separator: ",\n"))
        ) {
            \(raw: membersInfo.map { memberInfo in
                "self.\(memberInfo.name) = \(memberInfo.name)"
            }.joined(separator: "\n"))
        }
        """
    }
    
    fileprivate static func generateMutatingProperty(_ property: VariableDeclSyntax, allMembersInfo: [MemberBasicInfo]) -> DeclSyntax? {
        guard let propertyMemberInfo = property.memberBasicInfo else { return nil }
        
        let propertyMemberName = propertyMemberInfo.name
        let secondCharactetIndex = propertyMemberName.index(propertyMemberName.startIndex, offsetBy: 1)
        let newParameterName = "new\(propertyMemberName.first!.uppercased())\(propertyMemberName[secondCharactetIndex...])"
        
        return """
            public func with(\(raw: newParameterName): \(raw: propertyMemberInfo.type)) -> Self {
                .init(
                \(raw: allMembersInfo.map { memberInfo in
                    if memberInfo.name == propertyMemberName {
                        "\(memberInfo.name): \(newParameterName)"
                    }
                    else {  
                        "\(memberInfo.name): \(memberInfo.name)"
                    }
                }.joined(separator: ",\n"))
                )
            }
        """
    }
    
}
