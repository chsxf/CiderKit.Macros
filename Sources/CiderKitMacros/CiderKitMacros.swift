import CiderKitMacrosCommon

@attached(member, names: named(init), named(mutated))
public macro MutableStruct(initAccessLevel: AccessLevel? = nil) = #externalMacro(module: "CiderKitMacros_Macros", type: "MutableStructMacro")

@attached(peer)
public macro MutableStructOptional(defaultValue: String, keepValueDuringMutation: Bool = true) = #externalMacro(module: "CiderKitMacros_Macros", type: "MutableStructOptionalMacro")

@attached(peer)
public macro MutatingProperty(accessLevel: AccessLevel? = nil) = #externalMacro(module: "CiderKitMacros_Macros", type: "MutatingPropertyMacro")
