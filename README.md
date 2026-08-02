# CiderKit.Macros

A collection of Swift macros.

Originally designed for [CiderKit](https://github.com/chsxf/CiderKit), these macros can be used completely independently.

[![](https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg)](https://gitmoji.dev/)

# Macros

## `MutableStruct` and `MutatingProperty`

These two macros work together to simplify working with immutable structs that need to be copied with one value changed on a regular basis.

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
    
    public func with(newI: Int) -> Self {
        .init(i: newI, s: s, b: s)
    }
    
    public func with(newB: Bool) -> Self {
        .init(i: i, s: s, b: newB)
    }
}
```

You can then create modified version of the same value like this:

```swift
let t = TestStruct(i: 10, s: "Hellow, World!", b: true)
let t2 = t.with(newB: false)
let t3 = t.with(newI: 20)
```

# Installation with Swift Package Manager

CiderKit.Macros is available through [Swift Package Manager](https://github.com/apple/swift-package-manager).

## As a Package Dependency

To install it, simply add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/chsxf/CiderKit.Macros.git", from: "0.1.0"),
],
targets: [
    .target(name: "YourTarget", dependencies: ["CiderKit.Macros"]),
]
```

## As a Project Dependency in Xcode

- In Xcode, select **File > Add Packages...** and enter `https://github.com/chsxf/CiderKit.Macros.git` in the search field (top-right). 
- Then select **Up to Next Major Version** as the **Dependency Rule** with `0.1.0` in the associated text field.
- Then select the project of your choice in the **Add to Project** list.
- Finally, click the **Add Package** button.

# Support

Development on CiderKit.Macros is still active.

However, support is not guaranteed in any way. [Pull requests](https://github.com/chsxf/CiderKit.Macros/pulls) or [issues](https://github.com/chsxf/CiderKit.Macros/issues) are welcomed but you may wait for some time before getting any answer.

# License

Unless stated otherwise, all source code and assets are distributed under the [MIT License](LICENSE).
