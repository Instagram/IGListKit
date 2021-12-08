// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "IGListKit",
    platforms: [ .iOS(.v9),
                 .tvOS(.v9),
                 .macOS(.v10_11),
    ],
    products: [
        .library(name: "IGListDiffKit",
                 targets: ["IGListDiffKit"]),
        .library(name: "IGListKit",
                 targets: ["IGListKit"]),
        .library(name: "IGListSwiftKit",
                 targets: ["IGListSwiftKit"]),
    ],
    targets: [
        .target(
            name: "IGListDiffKit",
            path: "Source/IGListDiffKit",
            publicHeadersPath: "modulemap",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Internal"),
                .unsafeFlags(["-xobjective-c++", "-fcxx-modules"])
            ]
        ),
        .target(
            name: "IGListKit",
            dependencies: ["IGListDiffKit"],
            path: "Source/IGListKit",
            publicHeadersPath: "modulemap",
            cSettings: [
                .headerSearchPath(".."),
                .headerSearchPath("../IGListDiffKit"),
                .headerSearchPath("../IGListDiffKit/Internal"),
                .headerSearchPath("."),
                .headerSearchPath("Internal"),
                .unsafeFlags(["-xobjective-c++", "-fcxx-modules"])
            ]
        ),
        .target(
            name: "IGListSwiftKit",
            dependencies: ["IGListKit"],
            path: "Source/IGListSwiftKit"
        ),
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx11
)
