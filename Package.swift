// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "IGListKit",
    platforms: [ .iOS(.v9),
                 .tvOS(.v9),
                 .macOS(.v10_15)
    ],
    products: [
        .library(name: "IGListDiffKit",
                 type: .static ,
                 targets: ["IGListDiffKit"]),
        .library(name: "IGListKit",
                 type: .static,
                 targets: ["IGListKit"]),
        .library(name: "IGListSwiftKit",
                 type: .static,
                 targets: ["IGListSwiftKit"]),
    ],
    targets: [
        .target(
            name: "IGListDiffKit",
            path: "Source/IGListDiffKit",
            cSettings: [
                .headerSearchPath("Internal")
            ]
        ),
        .target(
            name: "IGListKit",
            dependencies: ["IGListDiffKit"],
            path: "Source/IGListKit",
            cSettings: [
                .headerSearchPath("../IGListDiffKit/Internal"),
                .headerSearchPath("Internal"),
                .define("USE_PACKAGE_FROM_XCODE", to: "1"),
            ]
        ),
        .target(
            name: "IGListSwiftKit",
            dependencies: ["IGListKit"],
            path: "Source/IGListSwiftKit"
        ),
    ],
    cLanguageStandard: .gnu99,
    cxxLanguageStandard: .cxx11
)
