# SQLite Guide

<!-- TOC START -->
## Table of Contents
- [SQLite Guide](#sqlite-guide)
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Migration Steps](#migration-steps)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Related Documentation](#related-documentation)
<!-- TOC END -->


## Overview

This guide provides step-by-step instructions for performing SQLite database migrations using the iOS Database Migration Framework.

## Prerequisites

- SQLite database file
- Migration SQL scripts

## Migration Steps

1. **Initialize the Migration Manager**

```swift
let sqliteMigration = SQLiteMigrationManager(databasePath: "path/to/database.sqlite")
```

2. **Define Migration**

```swift
let migration = SQLiteMigration(
    version: 2,
    description: "Add user preferences table",
    sql: "CREATE TABLE user_preferences (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, theme TEXT DEFAULT 'light', notifications_enabled BOOLEAN DEFAULT 1, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users(id));"
)
```

3. **Execute Migration**

```swift
sqliteMigration.executeMigration(migration) { result in
    switch result {
    case .success:
        print("✅ SQLite migration successful")
    case .failure(let error):
        print("❌ SQLite migration failed: \(error)")
    }
}
```

## Best Practices

- Always backup before migration
- Use transactions for complex migrations
- Test migrations with sample data

## Troubleshooting

- **Migration failed:** Check SQL syntax and database file path
- **Data loss:** Ensure all columns and tables are correctly defined

## Related Documentation

- [SQLite API](SQLiteAPI.md)
- [Migration Manager API](MigrationManagerAPI.md)
