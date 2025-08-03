# iOS Database Migration Framework

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen.svg)](CHANGELOG.md)

A powerful and comprehensive database migration framework for iOS applications, providing advanced version control, rollback capabilities, and data integrity tools for Core Data and SwiftData.

## 🚀 Features

### Core Features
- **Version Control**: Advanced database schema versioning with semantic versioning support
- **Rollback Capabilities**: Complete rollback functionality with data preservation
- **Data Integrity Validation**: Comprehensive data validation and integrity checks
- **Migration Analytics**: Detailed analytics and reporting for migration operations
- **Conflict Resolution**: Intelligent conflict detection and resolution strategies

### Core Data Support
- **Automatic Schema Detection**: Intelligent schema analysis and migration planning
- **Incremental Migrations**: Efficient incremental migration support
- **Custom Migration Policies**: Flexible custom migration policy implementation
- **Performance Optimization**: Optimized migration performance for large datasets

### SwiftData Support
- **Schema Evolution**: Advanced schema evolution capabilities
- **Data Transformation**: Powerful data transformation and mapping tools
- **Migration Orchestration**: Sophisticated migration orchestration and coordination
- **Error Recovery**: Robust error handling and recovery mechanisms

### Enterprise Features
- **Multi-Environment Support**: Support for development, staging, and production environments
- **Audit Logging**: Comprehensive audit logging for compliance requirements
- **Performance Monitoring**: Real-time performance monitoring and metrics
- **Security Integration**: Enterprise-grade security and encryption support

## 📦 Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Database-Migration-Framework.git", from: "1.0.0")
]
```

### Core Data Integration

```swift
import DatabaseMigrationCoreData

let migrationManager = CoreDataMigrationManager()
migrationManager.configure(with: migrationConfig)
```

### SwiftData Integration

```swift
import DatabaseMigrationSwiftData

let swiftDataManager = SwiftDataMigrationManager()
swiftDataManager.configure(with: swiftDataConfig)
```

## 🛠 Usage

### Basic Migration Setup

```swift
import DatabaseMigration

// Configure migration manager
let config = MigrationConfiguration(
    currentVersion: "1.0.0",
    targetVersion: "2.0.0",
    enableRollback: true,
    enableAnalytics: true
)

let migrationManager = DatabaseMigrationManager(configuration: config)

// Perform migration
do {
    let result = try await migrationManager.migrate()
    print("Migration completed successfully: \(result)")
} catch {
    print("Migration failed: \(error)")
}
```

### Advanced Migration with Custom Policies

```swift
import DatabaseMigrationCoreData

// Create custom migration policy
let customPolicy = CustomMigrationPolicy { context in
    // Custom migration logic
    try await performCustomMigration(in: context)
}

// Configure with custom policy
let config = CoreDataMigrationConfiguration(
    modelVersions: ["1.0.0", "1.1.0", "2.0.0"],
    customPolicies: [customPolicy],
    enableValidation: true
)

let manager = CoreDataMigrationManager(configuration: config)
```

### SwiftData Schema Evolution

```swift
import DatabaseMigrationSwiftData

// Define schema evolution
let schemaEvolution = SchemaEvolution()
    .addEntity("User", properties: [
        "id": .uuid,
        "name": .string,
        "email": .string,
        "createdAt": .date
    ])
    .addEntity("Post", properties: [
        "id": .uuid,
        "title": .string,
        "content": .string,
        "authorId": .uuid,
        "publishedAt": .date
    ])

// Configure SwiftData migration
let config = SwiftDataMigrationConfiguration(
    schemaEvolution: schemaEvolution,
    enableDataTransformation: true,
    enableConflictResolution: true
)

let manager = SwiftDataMigrationManager(configuration: config)
```

### Migration Analytics

```swift
import DatabaseMigration

// Configure analytics
let analyticsConfig = MigrationAnalyticsConfiguration(
    enablePerformanceMetrics: true,
    enableDataIntegrityChecks: true,
    enableAuditLogging: true
)

let analytics = MigrationAnalytics(configuration: analyticsConfig)

// Monitor migration progress
analytics.onProgress { progress in
    print("Migration progress: \(progress.percentage)%")
}

analytics.onCompletion { result in
    print("Migration analytics: \(result)")
}
```

## 📚 Documentation

- [API Documentation](Documentation/API/)
- [Migration Guides](Documentation/Guides/)
- [Tutorials](Documentation/Tutorials/)
- [Examples](Examples/)

## 🧪 Testing

Run the test suite:

```bash
swift test
```

Run specific test categories:

```bash
swift test --filter DatabaseMigrationTests
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Acknowledgments

- Apple for Core Data and SwiftData frameworks
- Swift community for excellent tooling and libraries
- Contributors and maintainers

## 📞 Support

- [Issues](https://github.com/muhittincamdali/iOS-Database-Migration-Framework/issues)
- [Discussions](https://github.com/muhittincamdali/iOS-Database-Migration-Framework/discussions)
- [Documentation](Documentation/)

---

**Made with ❤️ for the iOS development community**
