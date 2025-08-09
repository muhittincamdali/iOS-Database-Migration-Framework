# Data Migration API

<!-- TOC START -->
## Table of Contents
- [Data Migration API](#data-migration-api)
- [Overview](#overview)
- [Core Components](#core-components)
  - [DataMigrationManager](#datamigrationmanager)
  - [DataTransformation](#datatransformation)
- [API Reference](#api-reference)
  - [Data Operations](#data-operations)
    - [Basic Data Migration](#basic-data-migration)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Related Documentation](#related-documentation)
<!-- TOC END -->


## Overview

The Data Migration API provides comprehensive data transformation and migration capabilities, enabling seamless data restructuring, format conversion, and bulk data operations across multiple database types.

## Core Components

### DataMigrationManager

The main entry point for data migration operations.

```swift
public class DataMigrationManager {
    public init()
    public func migrateData(transformation: DataTransformation, completion: @escaping (Result<DataMigrationResult, MigrationError>) -> Void)
    public func validateDataTransformation(_ transformation: DataTransformation) -> Bool
}
```

### DataTransformation

Represents data transformation operations.

```swift
public class DataTransformation {
    public func transformTable(_ tableName: String, transformation: @escaping (DataRow, DataRow) -> Void)
    public func copyData(from sourceTable: String, to targetTable: String, mapping: [String: String])
    public func filterData(tableName: String, condition: String)
}
```

## API Reference

### Data Operations

#### Basic Data Migration

```swift
let dataMigration = DataMigrationManager()

let dataTransformation = DataTransformation()
dataTransformation.transformTable("users") { oldData, newData in
    for row in oldData {
        let newRow = newData.createRow()
        newRow["id"] = row["id"]
        newRow["name"] = row["first_name"] + " " + row["last_name"]
        newRow["email"] = row["email_address"]
        newRow["created_at"] = row["registration_date"]
    }
}

dataMigration.migrateData(transformation: dataTransformation) { result in
    switch result {
    case .success(let migrationResult):
        print("✅ Data migration successful")
        print("Records migrated: \(migrationResult.recordsMigrated)")
        print("Migration time: \(migrationResult.migrationTime)s")
    case .failure(let error):
        print("❌ Data migration failed: \(error)")
    }
}
```

## Best Practices

1. **Validate data transformations before applying**
2. **Use batch processing for large datasets**
3. **Backup data before major transformations**
4. **Test transformations with sample data**
5. **Monitor data integrity during migration**

## Examples

See the [Data Migration Examples](../Examples/AdvancedExamples/) directory for comprehensive usage examples.

## Related Documentation

- [Migration Manager API](MigrationManagerAPI.md)
- [Schema Migration API](SchemaMigrationAPI.md)
- [Performance API](PerformanceAPI.md)
