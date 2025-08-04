# Realm Guide

## Overview

This guide provides step-by-step instructions for performing Realm database migrations using the iOS Database Migration Framework.

## Prerequisites

- Realm database file
- Schema versioning

## Migration Steps

1. **Initialize the Migration Manager**

```swift
let realmMigration = RealmMigrationManager()
```

2. **Configure Migration**

```swift
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
```

3. **Perform Migration**

```swift
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

- Always backup before migration
- Use schema versioning properly
- Test migrations with sample data

## Troubleshooting

- **Migration failed:** Check schema version and migration block
- **Data loss:** Ensure all properties are mapped

## Related Documentation

- [Realm API](RealmAPI.md)
- [Migration Manager API](MigrationManagerAPI.md)
