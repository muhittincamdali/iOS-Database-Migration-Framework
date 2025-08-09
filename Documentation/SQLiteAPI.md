# SQLite API

<!-- TOC START -->
## Table of Contents
- [SQLite API](#sqlite-api)
- [Overview](#overview)
- [Core Components](#core-components)
  - [SQLiteMigrationManager](#sqlitemigrationmanager)
  - [SQLiteMigration](#sqlitemigration)
- [API Reference](#api-reference)
  - [Migration Operations](#migration-operations)
    - [Basic Migration](#basic-migration)
    - [Multiple Migrations](#multiple-migrations)
  - [Schema Management](#schema-management)
  - [Data Operations](#data-operations)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Related Documentation](#related-documentation)
<!-- TOC END -->


## Overview

The SQLite API provides direct SQLite database migration capabilities, enabling schema evolution, data transformation, and version management for SQLite databases in iOS applications.

## Core Components

### SQLiteMigrationManager

The main entry point for SQLite migration operations.

```swift
public class SQLiteMigrationManager {
    public init(databasePath: String)
    public func executeMigration(_ migration: SQLiteMigration, completion: @escaping (Result<Void, MigrationError>) -> Void)
    public func executeMigrations(_ migrations: [SQLiteMigration], completion: @escaping (Result<Void, MigrationError>) -> Void)
    public func rollbackToVersion(_ version: Int, completion: @escaping (Result<Void, MigrationError>) -> Void)
}
```

### SQLiteMigration

Represents a single SQLite migration operation.

```swift
public struct SQLiteMigration {
    public let version: Int
    public let description: String
    public let sql: String
    public let rollbackSQL: String?
    
    public init(version: Int, description: String, sql: String, rollbackSQL: String? = nil)
}
```

## API Reference

### Migration Operations

#### Basic Migration

```swift
let sqliteMigration = SQLiteMigrationManager(databasePath: "path/to/database.sqlite")

let migration = SQLiteMigration(
    version: 2,
    description: "Add user preferences table",
    sql: """
    CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        theme TEXT DEFAULT 'light',
        notifications_enabled BOOLEAN DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    );
    """,
    rollbackSQL: "DROP TABLE user_preferences;"
)

sqliteMigration.executeMigration(migration) { result in
    switch result {
    case .success:
        print("✅ SQLite migration successful")
    case .failure(let error):
        print("❌ SQLite migration failed: \(error)")
    }
}
```

#### Multiple Migrations

```swift
let migrations = [
    SQLiteMigration(version: 1, description: "Create users table", sql: "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);"),
    SQLiteMigration(version: 2, description: "Add email column", sql: "ALTER TABLE users ADD COLUMN email TEXT;"),
    SQLiteMigration(version: 3, description: "Add created_at column", sql: "ALTER TABLE users ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;")
]

sqliteMigration.executeMigrations(migrations) { result in
    // Handle result
}
```

### Schema Management

```swift
public class SQLiteSchemaManager {
    public func getCurrentSchema() -> [String: [String]]
    public func getTableInfo(tableName: String) -> [String: String]
    public func tableExists(tableName: String) -> Bool
    public func columnExists(tableName: String, columnName: String) -> Bool
}
```

### Data Operations

```swift
public class SQLiteDataManager {
    public func backupTable(tableName: String, backupTableName: String) -> Bool
    public func restoreTable(tableName: String, backupTableName: String) -> Bool
    public func copyData(from sourceTable: String, to targetTable: String, mapping: [String: String]) -> Bool
}
```

## Best Practices

1. **Always include rollback SQL when possible**
2. **Test migrations with sample data**
3. **Use transactions for complex migrations**
4. **Backup before major schema changes**
5. **Handle foreign key constraints properly**
6. **Monitor migration performance**

## Examples

See the [SQLite Examples](../Examples/SQLiteExamples/) directory for comprehensive usage examples.

## Related Documentation

- [Migration Manager API](MigrationManagerAPI.md)
- [Schema Migration API](SchemaMigrationAPI.md)
- [Data Migration API](DataMigrationAPI.md)
- [SQLite Guide](SQLiteGuide.md)
