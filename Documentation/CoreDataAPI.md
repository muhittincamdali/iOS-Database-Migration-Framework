# Core Data API

## Overview

The Core Data API provides comprehensive migration capabilities for Core Data managed object models. This API enables seamless schema evolution, lightweight and heavyweight migrations, and data transformation for Core Data applications.

## Core Components

### CoreDataMigrationManager

The main entry point for Core Data migration operations.

```swift
public class CoreDataMigrationManager {
    public init()
    public func migrate(from sourceModel: String, to targetModel: String, configuration: CoreDataMigrationConfiguration, completion: @escaping (Result<CoreDataMigrationResult, MigrationError>) -> Void)
    public func canMigrate(from sourceModel: String, to targetModel: String) -> Bool
    public func createMigrationMapping(from sourceModel: String, to targetModel: String) -> NSMappingModel?
}
```

### CoreDataMigrationConfiguration

Configuration options for Core Data migration operations.

```swift
public struct CoreDataMigrationConfiguration {
    public var enableAutomaticMigration: Bool
    public var enableLightweightMigration: Bool
    public var enableHeavyweightMigration: Bool
    public var backupBeforeMigration: Bool
    public var allowInferringMappingModel: Bool
    public var shouldDeleteOldModelOnSuccess: Bool
}
```

## API Reference

### Migration Operations

#### Lightweight Migration

```swift
let coreDataMigration = CoreDataMigrationManager()
let config = CoreDataMigrationConfiguration()
config.enableLightweightMigration = true
config.backupBeforeMigration = true

coreDataMigration.migrate(
    from: "UserModel_v1",
    to: "UserModel_v2",
    configuration: config
) { result in
    switch result {
    case .success(let migrationResult):
        print("✅ Core Data migration successful")
        print("Migrated records: \(migrationResult.migratedRecords)")
        print("Migration time: \(migrationResult.migrationTime)s")
    case .failure(let error):
        print("❌ Core Data migration failed: \(error)")
    }
}
```

#### Heavyweight Migration

```swift
let config = CoreDataMigrationConfiguration()
config.enableHeavyweightMigration = true
config.allowInferringMappingModel = true

coreDataMigration.migrate(
    from: "UserModel_v1",
    to: "UserModel_v3",
    configuration: config
) { result in
    // Handle result
}
```

### Model Version Management

```swift
public class CoreDataModelVersionManager {
    public func getCurrentModelVersion() -> String
    public func getAvailableModelVersions() -> [String]
    public func isMigrationRequired() -> Bool
    public func getMigrationPath(from sourceVersion: String, to targetVersion: String) -> [String]
}
```

### Custom Migration

```swift
public class CoreDataCustomMigration {
    public func createCustomMappingModel(from sourceModel: NSManagedObjectModel, to targetModel: NSManagedObjectModel) -> NSMappingModel
    public func performCustomMigration(sourceContext: NSManagedObjectContext, targetContext: NSManagedObjectContext)
}
```

## Best Practices

1. **Use lightweight migration when possible**
2. **Test migrations with sample data**
3. **Backup before major schema changes**
4. **Use custom migration for complex transformations**
5. **Monitor migration performance**
6. **Handle migration errors gracefully**

## Examples

See the [Core Data Examples](../Examples/CoreDataExamples/) directory for comprehensive usage examples.

## Related Documentation

- [Migration Manager API](MigrationManagerAPI.md)
- [Schema Migration API](SchemaMigrationAPI.md)
- [Data Migration API](DataMigrationAPI.md)
- [Core Data Guide](CoreDataGuide.md)
