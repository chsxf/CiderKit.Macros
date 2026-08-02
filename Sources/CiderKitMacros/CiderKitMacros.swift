@attached(member, names: arbitrary)
public macro MutableStruct() = #externalMacro(module: "CiderKitMacros_Macros", type: "MutableStructMacro")

@attached(peer)
public macro MutatingProperty() = #externalMacro(module: "CiderKitMacros_Macros", type: "MutatingPropertyMacro")
