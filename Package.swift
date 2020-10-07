// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "IGListKit",
    platforms: [ .iOS(.v9),
                 .tvOS(.v9),
                 .macOS(.v10_13)
    ],
    products: [
        .library(name: "IGListDiffKit",
                 type: .static ,
                 targets: ["IGListDiffKit"]),
        .library(name: "IGListKit",
                 type: .static,
                 targets: ["IGListKit"]),
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
                .headerSearchPath("IGListDiffKit/Internal"),
                .headerSearchPath("Internal")
            ]
        ),
    ],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)
