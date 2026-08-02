@attached(member, names: named(init), named(mutated))
public macro MutableStruct() = #externalMacro(module: "CiderKitMacros_Macros", type: "MutableStructMacro")

@attached(peer)
public macro MutatingProperty() = #externalMacro(module: "CiderKitMacros_Macros", type: "MutatingPropertyMacro")
