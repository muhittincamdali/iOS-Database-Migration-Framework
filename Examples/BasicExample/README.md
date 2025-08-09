# Basic Example

<!-- TOC START -->
## Table of Contents
- [Basic Example](#basic-example)
- [Overview](#overview)
- [Setup](#setup)
  - [1. Import the Framework](#1-import-the-framework)
  - [2. Create Configuration](#2-create-configuration)
  - [3. Initialize Manager](#3-initialize-manager)
- [Basic Migration](#basic-migration)
- [Migration with Progress Tracking](#migration-with-progress-tracking)
- [Schema Validation](#schema-validation)
- [Rollback Example](#rollback-example)
- [Analytics Example](#analytics-example)
- [Error Handling](#error-handling)
- [Complete Example](#complete-example)
- [Testing](#testing)
- [Best Practices](#best-practices)
<!-- TOC END -->


## Overview

This example demonstrates basic usage of the iOS Database Migration Framework.

## Setup

### 1. Import the Framework

```swift
import DatabaseMigration
```

### 2. Create Configuration

```swift
let config = MigrationConfiguration(
    currentVersion: "1.0.0",
    targetVersion: "2.0.0",
    enableRollback: true,
    enableAnalytics: true
)
```

### 3. Initialize Manager

```swift
let manager = MigrationManager(configuration: config)
```

## Basic Migration

```swift
// Simple migration without progress tracking
do {
    let result = try await manager.migrate()
    print("Migration successful: \(result)")
} catch {
    print("Migration failed: \(error)")
}
```

## Migration with Progress Tracking

```swift
// Migration with progress monitoring
let progressHandler: ProgressHandler = { progress in
    print("Progress: \(progress.percentage)% - \(progress.stage)")
}

do {
    let result = try await manager.migrate(progressHandler: progressHandler)
    print("Migration successful: \(result)")
} catch {
    print("Migration failed: \(error)")
}
```

## Schema Validation

```swift
// Validate schema before migration
do {
    let validationResult = try await manager.validateSchema()
    
    if validationResult.isValid {
        print("Schema validation passed")
        
        // Proceed with migration
        let result = try await manager.migrate()
        print("Migration successful")
        
    } else {
        print("Schema validation failed: \(validationResult.errors)")
    }
} catch {
    print("Validation failed: \(error)")
}
```

## Rollback Example

```swift
// Check if rollback is available
let history = manager.getMigrationHistory()

if !history.isEmpty {
    do {
        let rollbackResult = try await manager.rollback()
        print("Rollback successful to: \(rollbackResult.targetVersion)")
    } catch {
        print("Rollback failed: \(error)")
    }
} else {
    print("No migration history available")
}
```

## Analytics Example

```swift
// Get migration analytics
let analytics = manager.getAnalytics()

if let data = analytics {
    print("Success rate: \(data.successRate * 100)%")
    print("Total migrations: \(data.successfulMigrations)")
    print("Failed migrations: \(data.failedMigrations)")
    print("Average time: \(data.averageMigrationTime) seconds")
}
```

## Error Handling

```swift
do {
    let result = try await manager.migrate()
    print("Migration successful")
} catch MigrationError.invalidCurrentVersion {
    print("Invalid current version")
} catch MigrationError.schemaValidationFailed(let errors) {
    print("Schema validation failed: \(errors)")
} catch MigrationError.noRollbackAvailable {
    print("No rollback available")
} catch {
    print("Unexpected error: \(error)")
}
```

## Complete Example

```swift
import DatabaseMigration

class MigrationExample {
    
    private let manager: MigrationManager
    
    init() {
        let config = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        
        self.manager = MigrationManager(configuration: config)
    }
    
    func performMigration() async {
        // Validate schema first
        do {
            let validationResult = try await manager.validateSchema()
            
            if validationResult.isValid {
                print("Schema validation passed")
                
                // Perform migration with progress tracking
                let progressHandler: ProgressHandler = { progress in
                    print("Progress: \(progress.percentage)% - \(progress.stage)")
                }
                
                let result = try await manager.migrate(progressHandler: progressHandler)
                print("Migration successful: \(result)")
                
                // Get analytics
                let analytics = manager.getAnalytics()
                if let data = analytics {
                    print("Success rate: \(data.successRate * 100)%")
                }
                
            } else {
                print("Schema validation failed: \(validationResult.errors)")
            }
            
        } catch {
            print("Migration failed: \(error)")
            
            // Attempt rollback
            do {
                let rollbackResult = try await manager.rollback()
                print("Rollback successful to: \(rollbackResult.targetVersion)")
            } catch {
                print("Rollback failed: \(error)")
            }
        }
    }
}

// Usage
let example = MigrationExample()
await example.performMigration()
```

## Testing

```swift
import XCTest
@testable import DatabaseMigration

class MigrationExampleTests: XCTestCase {
    
    var manager: MigrationManager!
    
    override func setUp() {
        super.setUp()
        
        let config = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        
        manager = MigrationManager(configuration: config)
    }
    
    func testBasicMigration() async throws {
        let result = try await manager.migrate()
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.fromVersion, "1.0.0")
        XCTAssertEqual(result.toVersion, "2.0.0")
    }
    
    func testSchemaValidation() async throws {
        let result = try await manager.validateSchema()
        XCTAssertTrue(result.isValid)
    }
    
    func testAnalytics() {
        let analytics = manager.getAnalytics()
        XCTAssertNotNil(analytics)
    }
}
```

## Best Practices

1. **Always validate schema before migration**
2. **Use progress handlers for user feedback**
3. **Implement proper error handling**
4. **Enable rollback for safety**
5. **Monitor analytics for insights**
6. **Test thoroughly before production**
7. **Document your migration process**
8. **Have a rollback strategy ready**
