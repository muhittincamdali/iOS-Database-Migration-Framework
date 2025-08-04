# Schema Evolution Guide

## Overview

This guide provides step-by-step instructions for evolving your database schema using the iOS Database Migration Framework.

## Prerequisites

- Database schema definition
- Migration steps

## Schema Evolution Steps

1. **Initialize the Schema Migration Manager**

```swift
let schemaMigration = SchemaMigrationManager()
```

2. **Define Schema Changes**

```swift
let schemaChanges = SchemaChanges()
schemaChanges.addTable("user_preferences", columns: [
    Column("id", type: .integer, primaryKey: true),
    Column("user_id", type: .integer, foreignKey: "users.id"),
    Column("theme", type: .text, defaultValue: "light"),
    Column("notifications_enabled", type: .boolean, defaultValue: true)
])
```

3. **Execute Schema Migration**

```swift
schemaMigration.migrateSchema(changes: schemaChanges) { result in
    switch result {
    case .success(let migrationResult):
        print("✅ Schema migration successful")
        print("Tables created: \(migrationResult.tablesCreated)")
    case .failure(let error):
        print("❌ Schema migration failed: \(error)")
    }
}
```

## Best Practices

- Validate schema changes before applying
- Use transactions for complex changes
- Test schema changes thoroughly

## Troubleshooting

- **Migration failed:** Check schema definitions and constraints
- **Data loss:** Ensure all columns and tables are correctly defined

## Related Documentation

- [Schema Migration API](SchemaMigrationAPI.md)
- [Migration Manager API](MigrationManagerAPI.md)
