// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AlgebraDomainLanguage",
    products: [
        .library(
            name: "AlgebraDomainLanguage",
            targets: ["AlgebraDomainLanguage"]
        ),
    ],
    targets: [
        .target(
            name: "AlgebraDomainLanguage"
        ),
        .testTarget(
            name: "AlgebraDomainLanguageTests",
            dependencies: ["AlgebraDomainLanguage"]
        ),
    ]
)
