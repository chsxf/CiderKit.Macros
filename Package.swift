// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CiderKit.Macros",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CiderKit.Macros",
            targets: ["CiderKitMacros"]
        ),
        .executable(
            name: "CiderKit.Macros_Client",
            targets: ["CiderKitMacros_Client"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0-latest")
    ],
    targets: [
        .target(name: "CiderKitMacrosCommon"),

        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "CiderKitMacros_Macros",
            dependencies: [
                "CiderKitMacrosCommon",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "CiderKitMacros", dependencies: ["CiderKitMacros_Macros", "CiderKitMacrosCommon"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "CiderKitMacros_Client", dependencies: ["CiderKitMacros"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "CiderKitMacros_Tests",
            dependencies: [
                "CiderKitMacros_Macros",
                "CiderKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
