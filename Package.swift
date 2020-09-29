// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wiktionary",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Wiktionary",
            targets: ["Wiktionary"]),
    ],
    dependencies: [.package(name: "Ji", url: "https://github.com/honghaoz/Ji.git", .branch("master")),
                   .package(name: "StringTools", url: "https://github.com/shinjukunian/StringTools.git", .branch("master"))
                    
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "Wiktionary", dependencies: ["Ji", "StringTools"], path: nil, exclude: [String](), sources: nil, resources: [.copy("jawiktionary.xml")], publicHeadersPath: nil, cSettings: nil, cxxSettings: nil, swiftSettings: nil, linkerSettings: nil),
            
           
        .testTarget(
            name: "WiktionaryTests",
            dependencies: ["Wiktionary"]),
    ]
)
