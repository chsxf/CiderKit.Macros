# CiderKit.Macros

A collection of Swift macros.

Originally designed for [CiderKit](https://github.com/chsxf/CiderKit), these macros can be used completely independently.

[![](https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg)](https://gitmoji.dev/)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchsxf%2FCiderKit.Macros%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/chsxf/CiderKit.Macros)
[![Lint, Build & Test](https://github.com/chsxf/CiderKit.Macros/actions/workflows/swift.yml/badge.svg)](https://github.com/chsxf/CiderKit.Macros/actions/workflows/swift.yml)

# Macros

## `MutableStruct` and `MutatingProperty`

These two macros work together to simplify working with immutable structs (for example, `Sendable` structs) that need to be copied with one value changed on a regular basis.

The `MutableStruct` macro is applied on the enclosing struct, and the `MutableProperty` on the enclosed stored properties that you may want to change.

For example, this struct:

```swift
@MutableStruct
struct TestStruct {
    @MutableProperty public let i: Int
    public let s: String
    @MutableProperty public let b: Bool
}
```

will be expanded as follows:

```swift
struct TestStruct {
    public let i: Int
    public let s: String
    public let b: Bool
    
    public init(i: Int, s: String, b: Bool) {
        self.i = i
        self.s = s
        self.b = b
    }
    
    public func mutated(withI newI: Int) -> Self {
        .init(i: newI, s: s, b: s)
    }
    
    public func mutated(withB newB: Bool) -> Self {
        .init(i: i, s: s, b: newB)
    }
}
```

You can then create modified version of the same value like this:

```swift
let t = TestStruct(i: 10, s: "Hellow, World!", b: true)
let t2 = t.mutated(withB: false)
let t3 = t.mutated(withI: 20)
```

> [!TIP]
> You can provide custom implementation of the initiliazers or the `mutated` functions. The macro will detect their presence automatically and avoid generating its own version instead.

## `MutableStructOptional`

This macro must be used in association with `MutableStruct`.

It is useful in the rare cases where you want to be able to reinitialize a property to some default value when mutated, or if you want to use an external source as the value of a property.

You can also combine this macro with the `MutatingProperty` macro.

For example, this struct:

```swift
@MutableStruct
struct TestStruct {
    @MutableProperty public let i: Int
    @MutableStructOptional(defaultValue: "\"Hello, world!\"") @MutatingProperty public let s: String
    @MutableStructOptional(defaultValue: "3.2", keepValueDuringMutation: false) public let f: Float
}
```

will be expanded as follows:

```swift
struct TestStruct {
    public let i: Int
    public let s: String
    public let f: Float

    public init(i: Int, s: String? = nil, f: Float? = nil) {
        self.i = i
        self.s = s ?? "Hello, world!"
        self.f = f ?? 3.2;
    }

    public func mutated(withI newI: Int) -> Self {
        .init(i: newI, s: s)
    }

    public func mutated(withS newS: String) -> Self {
        .init(i: i, s: newS)
    }
}
```

### Parameters

The `MutableStructOptional` macro has two parameters:

| Name                      | Type     | Description                                                                                                                                                                                                   |
| ------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `defaultValue`            | `String` | Default value for the "optional" parameter. If the default value must be a string itself, it must be escaped in the macro (see example above).                                                                |
| `keepValueDuringMutation` | `Bool`   | If `true` (the default), the current value of the property will be kept during the mutation of another property. If `false`, the value of the property will be reset during the mutation of another property. |

# Installation with Swift Package Manager

CiderKit.Macros is available through [Swift Package Manager](https://github.com/apple/swift-package-manager).

## As a Package Dependency

To install it, simply add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/chsxf/CiderKit.Macros.git", from: "0.3.0"),
],
targets: [
    .target(name: "YourTarget", dependencies: ["CiderKit.Macros"]),
]
```

## As a Project Dependency in Xcode

- In Xcode, select **File > Add Packages...** and enter `https://github.com/chsxf/CiderKit.Macros.git` in the search field (top-right). 
- Then select **Up to Next Major Version** as the **Dependency Rule** with `0.3.0` in the associated text field.
- Then select the project of your choice in the **Add to Project** list.
- Finally, click the **Add Package** button.

# Support

Development on CiderKit.Macros is still active.

However, support is not guaranteed in any way. [Pull requests](https://github.com/chsxf/CiderKit.Macros/pulls) or [issues](https://github.com/chsxf/CiderKit.Macros/issues) are welcomed but you may wait for some time before getting any answer.

# License

Unless stated otherwise, all source code and assets are distributed under the [MIT License](LICENSE).
