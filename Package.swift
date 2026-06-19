// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "KeyThock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "KeyThock", targets: ["KeyThock"])
    ],
    targets: [
        .executableTarget(
            name: "KeyThock",
            path: "Sources/KeyThock",
            resources: [
                .copy("Resources")
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Carbon"),
                .linkedFramework("ServiceManagement")
            ]
        )
    ]
)
