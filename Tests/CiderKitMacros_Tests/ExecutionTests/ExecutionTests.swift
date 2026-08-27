import XCTest

final class ExecutionTests: XCTestCase {
    func testExecution() {
        let test = TestStruct(i: 10, b: true, s: helloWorld)
        assert(test.i == 10)
        assert(test.b)
        assert(test.s == helloWorld)

        let test2 = test.mutated(withB: false)
        assert(test2.i == 10)
        assert(test2.b == false)
        assert(test2.s == helloWorld)

        let test3 = test.mutated(withI: 20)
        assert(test3.i == 20)
        assert(test3.b == true)
        assert(test3.s == helloWorld)

        let test4 = test2.mutated(withI: 30)
        assert(test4.i == 30)
        assert(test4.b == false)
        assert(test4.s == helloWorld)
    }

    func testExecutionWithOptional() throws {
        let test = TestStructWithOptional(i: 10, b: true, s: helloWorld, initOptionalProperty: 5.4)
        assert(test.i == 10)
        assert(test.b)
        assert(test.s == helloWorld)
        assert(test.initOptionalProperty == 5.4)

        let test2 = test.mutated(withB: false)
        assert(test2.i == 10)
        assert(test2.b == false)
        assert(test2.s == helloWorld)
        assert(test2.initOptionalProperty == 5.4)

        let test3 = TestStructWithOptional(i: 10, b: true, s: helloWorld)
        assert(test3.i == 10)
        assert(test3.b)
        assert(test3.s == helloWorld)
        assert(test3.initOptionalProperty == 1.2)
    }

    func testExecutionWithMutatingOptional() throws {
        let test = TestStructWithMutatingOptional(i: 10, b: true, s: helloWorld, initOptionalProperty: 5.4)
        assert(test.i == 10)
        assert(test.b)
        assert(test.s == helloWorld)
        assert(test.initOptionalProperty == 5.4)

        let test2 = test.mutated(withInitOptionalProperty: 3.6)
        assert(test2.i == 10)
        assert(test2.b)
        assert(test2.s == helloWorld)
        assert(test2.initOptionalProperty == 3.6)

        let test3 = TestStructWithMutatingOptional(i: 10, b: true, s: helloWorld)
        assert(test3.i == 10)
        assert(test3.b)
        assert(test3.s == helloWorld)
        assert(test3.initOptionalProperty == 1.2)

        let test4 = test3.mutated(withInitOptionalProperty: 7.8)
        assert(test4.i == 10)
        assert(test4.b)
        assert(test4.s == helloWorld)
        assert(test4.initOptionalProperty == 7.8)
    }

    func testExecutionWithInitializedMember() throws {
        let test = TestStructWithInitializedMember(i: 10)
        assert(test.type == "test")
        assert(test.i == 10)

        let test2 = test.mutated(withI: 20)
        assert(test2.type == "test")
        assert(test2.i == 20)
    }
}
