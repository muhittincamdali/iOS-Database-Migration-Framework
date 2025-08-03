// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DatabaseMigration",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "DatabaseMigration", targets: ["DatabaseMigration"]),
        .library(name: "DatabaseMigrationCoreData", targets: ["DatabaseMigrationCoreData"]),
        .library(name: "DatabaseMigrationSwiftData", targets: ["DatabaseMigrationSwiftData"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DatabaseMigration",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            path: "Sources/DatabaseMigration/Core"
        ),
        .target(
            name: "DatabaseMigrationCoreData",
            dependencies: ["DatabaseMigration"],
            path: "Sources/DatabaseMigration/CoreData"
        ),
        .target(
            name: "DatabaseMigrationSwiftData",
            dependencies: ["DatabaseMigration"],
            path: "Sources/DatabaseMigration/SwiftData"
        ),
        .testTarget(
            name: "DatabaseMigrationTests",
            dependencies: [
                "DatabaseMigration",
                "DatabaseMigrationCoreData",
                "DatabaseMigrationSwiftData"
            ],
            path: "Tests/DatabaseMigrationTests"
        )
    ]
)
