// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "IGListKit",
    platforms: [ .iOS(.v13),
                 .tvOS(.v11),
                 .macOS(.v10_13),
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
            path: "spm/Sources/IGListDiffKit",
            publicHeadersPath: "include"
        ),
        .target(
            name: "IGListKit",
            dependencies: ["IGListDiffKit"],
            path: "spm/Sources/IGListKit",
            publicHeadersPath: "include"
        ),
        .target(
            name: "IGListSwiftKit",
            dependencies: ["IGListKit"],
            path: "spm/Sources/IGListSwiftKit"
        ),
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx11
)
