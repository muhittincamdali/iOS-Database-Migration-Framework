# Schema Migration API

<!-- TOC START -->
## Table of Contents
- [Schema Migration API](#schema-migration-api)
- [Overview](#overview)
- [Core Components](#core-components)
  - [SchemaMigrationManager](#schemamigrationmanager)
  - [SchemaChanges](#schemachanges)
- [API Reference](#api-reference)
  - [Schema Operations](#schema-operations)
    - [Basic Schema Migration](#basic-schema-migration)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Related Documentation](#related-documentation)
<!-- TOC END -->


## Overview

The Schema Migration API provides comprehensive database schema evolution capabilities, enabling seamless schema changes, table modifications, and structural updates across multiple database types.

## Core Components

### SchemaMigrationManager

The main entry point for schema migration operations.

```swift
public class SchemaMigrationManager {
    public init()
    public func migrateSchema(changes: SchemaChanges, completion: @escaping (Result<SchemaMigrationResult, MigrationError>) -> Void)
    public func validateSchemaChanges(_ changes: SchemaChanges) -> Bool
}
```

### SchemaChanges

Represents schema changes to be applied.

```swift
public class SchemaChanges {
    public func addTable(_ tableName: String, columns: [Column])
    public func addColumn(_ tableName: String, column: Column)
    public func modifyColumn(_ tableName: String, column: Column)
    public func dropTable(_ tableName: String)
    public func dropColumn(_ tableName: String, columnName: String)
}
```

## API Reference

### Schema Operations

#### Basic Schema Migration

```swift
let schemaMigration = SchemaMigrationManager()

let schemaChanges = SchemaChanges()
schemaChanges.addTable("user_preferences", columns: [
    Column("id", type: .integer, primaryKey: true),
    Column("user_id", type: .integer, foreignKey: "users.id"),
    Column("theme", type: .text, defaultValue: "light"),
    Column("notifications_enabled", type: .boolean, defaultValue: true)
])

schemaMigration.migrateSchema(changes: schemaChanges) { result in
    switch result {
    case .success(let migrationResult):
        print("✅ Schema migration successful")
        print("Tables created: \(migrationResult.tablesCreated)")
        print("Columns added: \(migrationResult.columnsAdded)")
    case .failure(let error):
        print("❌ Schema migration failed: \(error)")
    }
}
```

## Best Practices

1. **Validate schema changes before applying**
2. **Use transactions for complex changes**
3. **Handle foreign key constraints properly**
4. **Test schema changes thoroughly**
5. **Backup before major schema changes**

## Examples

See the [Schema Evolution Guide](SchemaEvolutionGuide.md) for comprehensive usage examples.

## Related Documentation

- [Migration Manager API](MigrationManagerAPI.md)
- [Core Data API](CoreDataAPI.md)
- [SQLite API](SQLiteAPI.md)
- [Realm API](RealmAPI.md)
