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
                 targets: ["IGListDiffKit"])
    ],
    targets: [
        .target(
            name: "IGListDiffKit",
            path: "Source/IGListDiffKit",
            exclude: ["include/IGListDiffKit.h"],
            cSettings: [
                .headerSearchPath("Internal")
            ]
        )
    ],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)
