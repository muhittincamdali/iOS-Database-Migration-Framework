# API Documentation

<!-- TOC START -->
## Table of Contents
- [API Documentation](#api-documentation)
- [Overview](#overview)
- [Core Components](#core-components)
  - [MigrationManager](#migrationmanager)
  - [SchemaValidator](#schemavalidator)
  - [MigrationAnalytics](#migrationanalytics)
- [Core Data Integration](#core-data-integration)
  - [CoreDataMigrationManager](#coredatamigrationmanager)
- [SwiftData Integration](#swiftdata-integration)
  - [SwiftDataMigrationManager](#swiftdatamigrationmanager)
- [Error Handling](#error-handling)
  - [MigrationError](#migrationerror)
- [Configuration](#configuration)
  - [MigrationConfiguration](#migrationconfiguration)
- [Progress Tracking](#progress-tracking)
  - [ProgressHandler](#progresshandler)
- [Analytics](#analytics)
  - [MigrationAnalyticsData](#migrationanalyticsdata)
- [Best Practices](#best-practices)
- [Performance Considerations](#performance-considerations)
- [Security](#security)
<!-- TOC END -->


## Overview

The iOS Database Migration Framework provides comprehensive database migration capabilities for iOS applications. This documentation covers all public APIs and their usage.

## Core Components

### MigrationManager

The main migration manager that orchestrates database migrations.

```swift
import DatabaseMigration

let config = MigrationConfiguration(
    currentVersion: "1.0.0",
    targetVersion: "2.0.0",
    enableRollback: true,
    enableAnalytics: true
)

let migrationManager = MigrationManager(configuration: config)
```

### SchemaValidator

Validates database schema integrity and structure.

```swift
import DatabaseMigration

let validator = SchemaValidator(configuration: config)
let result = try await validator.validate()
```

### MigrationAnalytics

Tracks migration performance and provides analytics.

```swift
import DatabaseMigration

let analytics = MigrationAnalytics(configuration: .init())
analytics.recordMigrationSuccess(result)
```

## Core Data Integration

### CoreDataMigrationManager

Handles Core Data specific migrations.

```swift
import DatabaseMigrationCoreData

let config = CoreDataMigrationConfiguration(
    modelVersions: ["1.0.0", "2.0.0"],
    enableValidation: true
)

let manager = CoreDataMigrationManager(configuration: config)
```

## SwiftData Integration

### SwiftDataMigrationManager

Handles SwiftData schema evolution and migrations.

```swift
import DatabaseMigrationSwiftData

let schemaEvolution = SchemaEvolution()
    .addEntity("User", properties: [
        "id": .uuid,
        "name": .string,
        "email": .string
    ])

let config = SwiftDataMigrationConfiguration(
    schemaEvolution: schemaEvolution,
    enableDataTransformation: true
)

let manager = SwiftDataMigrationManager(configuration: config)
```

## Error Handling

### MigrationError

All migration errors are of type `MigrationError`.

```swift
do {
    let result = try await migrationManager.migrate()
} catch MigrationError.invalidCurrentVersion {
    // Handle invalid version error
} catch MigrationError.schemaValidationFailed(let errors) {
    // Handle schema validation errors
} catch {
    // Handle other errors
}
```

## Configuration

### MigrationConfiguration

Main configuration for migration operations.

```swift
let config = MigrationConfiguration(
    currentVersion: "1.0.0",
    targetVersion: "2.0.0",
    enableRollback: true,
    enableAnalytics: true,
    enableBackup: true,
    logLevel: .info
)
```

## Progress Tracking

### ProgressHandler

Monitor migration progress in real-time.

```swift
let progressHandler: ProgressHandler = { progress in
    print("Migration progress: \(progress.percentage)%")
    print("Current stage: \(progress.stage)")
}

try await migrationManager.migrate(progressHandler: progressHandler)
```

## Analytics

### MigrationAnalyticsData

Access migration analytics and statistics.

```swift
let analytics = migrationManager.getAnalytics()
print("Success rate: \(analytics?.successRate ?? 0)")
print("Total migrations: \(analytics?.successfulMigrations ?? 0)")
print("Average time: \(analytics?.averageMigrationTime ?? 0)")
```

## Best Practices

1. **Always validate before migration**: Use `validateSchema()` before performing migrations
2. **Enable rollback**: Always enable rollback for production migrations
3. **Monitor progress**: Use progress handlers for long-running migrations
4. **Handle errors**: Implement proper error handling for all migration operations
5. **Test thoroughly**: Test migrations with realistic data before production deployment

## Performance Considerations

1. **Large datasets**: For large datasets, consider incremental migrations
2. **Memory usage**: Monitor memory usage during migrations
3. **Backup strategy**: Always create backups before major migrations
4. **Rollback planning**: Have a rollback strategy for critical migrations

## Security

1. **Data encryption**: Sensitive data should be encrypted during migration
2. **Access control**: Implement proper access controls for migration operations
3. **Audit logging**: Enable audit logging for compliance requirements
4. **Input validation**: Validate all inputs to prevent injection attacks
