import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CiderKit_MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MutableStructMacro.self,
        MutatingPropertyMacro.self
    ]
}
