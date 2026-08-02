import CiderKitMacros

@MutableStruct
struct TestStructWithMacros {
    
    @MutatingProperty public let i: Int
    @MutatingProperty public let b: Bool
    public let s: String
    
}
