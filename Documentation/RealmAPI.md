# Realm API

<!-- TOC START -->
## Table of Contents
- [Realm API](#realm-api)
- [Overview](#overview)
- [Core Components](#core-components)
  - [RealmMigrationManager](#realmmigrationmanager)
  - [Realm Migration Configuration](#realm-migration-configuration)
- [API Reference](#api-reference)
  - [Migration Operations](#migration-operations)
    - [Basic Migration](#basic-migration)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Related Documentation](#related-documentation)
<!-- TOC END -->


## Overview

The Realm API provides comprehensive migration capabilities for Realm databases, enabling seamless schema evolution and data transformation for Realm-based iOS applications.

## Core Components

### RealmMigrationManager

The main entry point for Realm migration operations.

```swift
public class RealmMigrationManager {
    public init()
    public func migrate(with configuration: Realm.Configuration, completion: @escaping (Result<Void, MigrationError>) -> Void)
    public func createMigrationBlock(from oldSchemaVersion: UInt64, to newSchemaVersion: UInt64) -> MigrationBlock
}
```

### Realm Migration Configuration

```swift
public struct RealmMigrationConfiguration {
    public var schemaVersion: UInt64
    public var migrationBlock: MigrationBlock?
    public var deleteRealmIfMigrationNeeded: Bool
    public var shouldCompactOnLaunch: Bool
}
```

## API Reference

### Migration Operations

#### Basic Migration

```swift
let realmMigration = RealmMigrationManager()

let realmConfig = Realm.Configuration(
    schemaVersion: 2,
    migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 2 {
            migration.enumerateObjects(ofType: User.className()) { oldObject, newObject in
                newObject!["preferences"] = ["theme": "light"]
            }
        }
    }
)

realmMigration.migrate(with: realmConfig) { result in
    switch result {
    case .success:
        print("✅ Realm migration successful")
    case .failure(let error):
        print("❌ Realm migration failed: \(error)")
    }
}
```

## Best Practices

1. **Always test migrations with sample data**
2. **Use schema versioning properly**
3. **Handle property additions and deletions carefully**
4. **Backup before major schema changes**
5. **Monitor migration performance**

## Examples

See the [Realm Examples](../Examples/RealmExamples/) directory for comprehensive usage examples.

## Related Documentation

- [Migration Manager API](MigrationManagerAPI.md)
- [Schema Migration API](SchemaMigrationAPI.md)
- [Data Migration API](DataMigrationAPI.md)
- [Realm Guide](RealmGuide.md)
