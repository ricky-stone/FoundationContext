// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "FoundationContext",
    platforms: [
        .iOS("26.4"),
        .macOS("26.4"),
        .visionOS("26.4")
    ],
    products: [
        .library(
            name: "FoundationContext",
            targets: ["FoundationContext"]
        ),
    ],
    targets: [
        .target(
            name: "FoundationContext"
        ),
        
    ],
    swiftLanguageModes: [.v6]
)
