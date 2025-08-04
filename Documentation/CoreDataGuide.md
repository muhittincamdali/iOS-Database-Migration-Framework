# Core Data Guide

## Overview

This guide provides step-by-step instructions for performing Core Data migrations using the iOS Database Migration Framework.

## Prerequisites

- Core Data model versions (source and target)
- Migration mapping model (if needed)

## Migration Steps

1. **Initialize the Migration Manager**

```swift
let coreDataMigration = CoreDataMigrationManager()
```

2. **Configure Migration**

```swift
let config = CoreDataMigrationConfiguration()
config.enableAutomaticMigration = true
config.enableLightweightMigration = true
config.backupBeforeMigration = true
```

3. **Perform Migration**

```swift
coreDataMigration.migrate(
    from: "UserModel_v1",
    to: "UserModel_v2",
    configuration: config
) { result in
    switch result {
    case .success(let migrationResult):
        print("✅ Core Data migration successful")
        print("Migrated records: \(migrationResult.migratedRecords)")
    case .failure(let error):
        print("❌ Core Data migration failed: \(error)")
    }
}
```

## Best Practices

- Always backup before migration
- Test migrations with sample data
- Use lightweight migration when possible
- Use custom mapping models for complex changes

## Troubleshooting

- **Migration failed:** Check model compatibility and mapping models
- **Data loss:** Ensure all entities and attributes are mapped

## Related Documentation

- [Core Data API](CoreDataAPI.md)
- [Migration Manager API](MigrationManagerAPI.md)
