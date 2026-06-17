// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ThockStudio",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ThockStudio", targets: ["ThockStudio"])
    ],
    targets: [
        .executableTarget(
            name: "ThockStudio",
            path: "Sources/ThockStudio",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
