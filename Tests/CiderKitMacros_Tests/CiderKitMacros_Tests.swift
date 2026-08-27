import SwiftSyntaxMacros
import CiderKitMacros_Macros

let testMacros: [String: Macro.Type] = [
    "MutableStruct": MutableStructMacro.self,
    "MutableStructOptional": MutableStructOptionalMacro.self,
    "MutatingProperty": MutatingPropertyMacro.self
]

let helloWorld = "Hello, World!"
