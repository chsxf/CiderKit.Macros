import CiderKitMacros

@MutableStruct
struct TestStruct {
    
    @MutatingProperty public let i: Int
    @MutatingProperty public let b: Bool
    public let s: String
    
}

@MutableStruct
struct TestStructWithOptional {

    @MutatingProperty public let i: Int
    @MutatingProperty public let b: Bool
    public let s: String
    @MutableStructOptional(defaultValue: "1.2") public let initOptionalProperty: Float
    @MutableStructOptional(defaultValue: "3.4", keepValueDuringMutation: false) public let initOptionalProperty2: Float

}

@MutableStruct
struct TestStructWithMutatingOptional {

    @MutatingProperty public let i: Int
    @MutatingProperty public let b: Bool
    public let s: String
    @MutableStructOptional(defaultValue: "1.2") @MutatingProperty public let initOptionalProperty: Float
    @MutableStructOptional(defaultValue: "3.4", keepValueDuringMutation: false) @MutatingProperty public let initOptionalProperty2: Float

}
