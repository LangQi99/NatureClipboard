// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "ClipboardManager",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ClipboardManager", targets: ["ClipboardManagerApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0")
    ],
    targets: [
        .executableTarget(
            name: "ClipboardManagerApp",
            dependencies: ["ClipboardManagerKit"],
            path: "ClipboardManager"
        ),
        .target(
            name: "ClipboardManagerKit",
            path: "Sources/ClipboardManagerKit"
        ),
        .testTarget(
            name: "ClipboardManagerKitTests",
            dependencies: [
                "ClipboardManagerKit",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests"
        ),
    ]
)
