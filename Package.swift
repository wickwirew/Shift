// swift-tools-version:5.2
let package = Package(
    name: "Shift",
    platforms: [
        .iOS("11.0"),
    ],
    products: [
        .library(name: "Shift", targets: ["Shift"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Shift",
            path: "Shift"
        ),
        .testTarget(
            name: "ShiftTests",
            dependencies: ["Shift"],
            path: "ShiftTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
