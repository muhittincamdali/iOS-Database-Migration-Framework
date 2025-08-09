# Tutorials

<!-- TOC START -->
## Table of Contents
- [Tutorials](#tutorials)
- [Tutorial 1: Basic Migration Setup](#tutorial-1-basic-migration-setup)
  - [Step 1: Install the Framework](#step-1-install-the-framework)
  - [Step 2: Import and Configure](#step-2-import-and-configure)
  - [Step 3: Perform Migration](#step-3-perform-migration)
- [Tutorial 2: Core Data Migration](#tutorial-2-core-data-migration)
  - [Step 1: Setup Core Data Migration](#step-1-setup-core-data-migration)
  - [Step 2: Create Custom Migration Policy](#step-2-create-custom-migration-policy)
  - [Step 3: Execute Migration](#step-3-execute-migration)
- [Tutorial 3: SwiftData Migration](#tutorial-3-swiftdata-migration)
  - [Step 1: Define Schema Evolution](#step-1-define-schema-evolution)
  - [Step 2: Configure SwiftData Migration](#step-2-configure-swiftdata-migration)
  - [Step 3: Execute Migration](#step-3-execute-migration)
- [Tutorial 4: Advanced Analytics](#tutorial-4-advanced-analytics)
  - [Step 1: Configure Analytics](#step-1-configure-analytics)
  - [Step 2: Monitor Migration Progress](#step-2-monitor-migration-progress)
  - [Step 3: Analyze Results](#step-3-analyze-results)
- [Tutorial 5: Error Handling and Rollback](#tutorial-5-error-handling-and-rollback)
  - [Step 1: Implement Error Handling](#step-1-implement-error-handling)
  - [Step 2: Implement Rollback](#step-2-implement-rollback)
  - [Step 3: Validate After Migration](#step-3-validate-after-migration)
- [Tutorial 6: Production Deployment](#tutorial-6-production-deployment)
  - [Step 1: Pre-Production Checklist](#step-1-pre-production-checklist)
  - [Step 2: Production Migration](#step-2-production-migration)
  - [Step 3: Post-Migration Validation](#step-3-post-migration-validation)
- [Best Practices Summary](#best-practices-summary)
<!-- TOC END -->


## Tutorial 1: Basic Migration Setup

### Step 1: Install the Framework

Add the framework to your project using Swift Package Manager:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Database-Migration-Framework.git", from: "1.0.0")
]
```

### Step 2: Import and Configure

```swift
import DatabaseMigration

// Create configuration
let config = MigrationConfiguration(
    currentVersion: "1.0.0",
    targetVersion: "2.0.0",
    enableRollback: true,
    enableAnalytics: true
)

// Initialize manager
let manager = MigrationManager(configuration: config)
```

### Step 3: Perform Migration

```swift
// Perform migration with progress tracking
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

## Tutorial 2: Core Data Migration

### Step 1: Setup Core Data Migration

```swift
import DatabaseMigrationCoreData

// Create Core Data configuration
let config = CoreDataMigrationConfiguration(
    modelVersions: ["1.0.0", "1.1.0", "2.0.0"],
    enableValidation: true,
    enableAnalytics: true
)

let manager = CoreDataMigrationManager(configuration: config)
```

### Step 2: Create Custom Migration Policy

```swift
let customPolicy = CustomMigrationPolicy { context in
    // Fetch all users
    let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "User")
    
    do {
        let users = try context.fetch(fetchRequest)
        
        // Apply migration logic
        for user in users {
            // Example: Update email format
            if let email = user.value(forKey: "email") as? String {
                user.setValue(email.lowercased(), forKey: "email")
            }
            
            // Example: Add new field with default value
            if user.value(forKey: "isActive") == nil {
                user.setValue(true, forKey: "isActive")
            }
        }
        
        try context.save()
    } catch {
        throw error
    }
}
```

### Step 3: Execute Migration

```swift
// Get your Core Data models
let sourceModel = // Your source NSManagedObjectModel
let targetModel = // Your target NSManagedObjectModel

do {
    let result = try await manager.migrate(
        from: sourceModel,
        to: targetModel
    )
    print("Core Data migration successful")
} catch {
    print("Core Data migration failed: \(error)")
}
```

## Tutorial 3: SwiftData Migration

### Step 1: Define Schema Evolution

```swift
import DatabaseMigrationSwiftData

// Define your schema evolution
let schemaEvolution = SchemaEvolution()
    .addEntity("User", properties: [
        "id": .uuid,
        "name": .string,
        "email": .string,
        "createdAt": .date,
        "isActive": .bool
    ])
    .addEntity("Post", properties: [
        "id": .uuid,
        "title": .string,
        "content": .string,
        "authorId": .uuid,
        "publishedAt": .date,
        "isPublished": .bool
    ])
```

### Step 2: Configure SwiftData Migration

```swift
let config = SwiftDataMigrationConfiguration(
    schemaEvolution: schemaEvolution,
    enableDataTransformation: true,
    enableConflictResolution: true,
    enableAnalytics: true
)

let manager = SwiftDataMigrationManager(configuration: config)
```

### Step 3: Execute Migration

```swift
do {
    let result = try await manager.migrate(
        schemaEvolution: schemaEvolution
    )
    print("SwiftData migration successful")
} catch {
    print("SwiftData migration failed: \(error)")
}
```

## Tutorial 4: Advanced Analytics

### Step 1: Configure Analytics

```swift
let analyticsConfig = MigrationAnalyticsConfiguration(
    enablePerformanceMetrics: true,
    enableDataIntegrityChecks: true,
    enableAuditLogging: true
)

let analytics = MigrationAnalytics(configuration: analyticsConfig)
```

### Step 2: Monitor Migration Progress

```swift
let progressHandler: ProgressHandler = { progress in
    // Update UI with progress
    DispatchQueue.main.async {
        updateProgressBar(percentage: progress.percentage)
        updateStatusLabel(stage: progress.stage)
    }
}
```

### Step 3: Analyze Results

```swift
// Get analytics data
let data = analytics.getAnalyticsData()

print("Success rate: \(data.successRate * 100)%")
print("Total migrations: \(data.successfulMigrations)")
print("Failed migrations: \(data.failedMigrations)")
print("Average time: \(data.averageMigrationTime) seconds")

// Access performance metrics
for metric in data.performanceMetrics {
    print("Migration at \(metric.timestamp): \(metric.duration)s")
}

// Access audit log
for entry in data.auditLog {
    print("\(entry.timestamp): \(entry.operation) - \(entry.success ? "Success" : "Failed")")
}
```

## Tutorial 5: Error Handling and Rollback

### Step 1: Implement Error Handling

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

### Step 2: Implement Rollback

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
    print("No migration history available for rollback")
}
```

### Step 3: Validate After Migration

```swift
// Validate schema after migration
do {
    let validationResult = try await manager.validateSchema()
    if validationResult.isValid {
        print("Schema validation passed")
    } else {
        print("Schema validation failed: \(validationResult.errors)")
    }
} catch {
    print("Validation failed: \(error)")
}
```

## Tutorial 6: Production Deployment

### Step 1: Pre-Production Checklist

1. **Backup your data**
2. **Test in staging environment**
3. **Validate schema compatibility**
4. **Prepare rollback plan**
5. **Monitor system resources**

### Step 2: Production Migration

```swift
// Production-ready migration
let config = MigrationConfiguration(
    currentVersion: "1.0.0",
    targetVersion: "2.0.0",
    enableRollback: true,
    enableAnalytics: true,
    enableBackup: true,
    logLevel: .info
)

let manager = MigrationManager(configuration: config)

// Monitor progress in production
let progressHandler: ProgressHandler = { progress in
    // Log progress for monitoring
    Logger.info("Migration progress: \(progress.percentage)%")
    
    // Update monitoring dashboard
    updateMonitoringDashboard(progress: progress)
}

do {
    let result = try await manager.migrate(progressHandler: progressHandler)
    
    // Log success
    Logger.info("Production migration completed successfully")
    
    // Send notification
    sendMigrationSuccessNotification(result: result)
    
} catch {
    // Log error
    Logger.error("Production migration failed: \(error)")
    
    // Send alert
    sendMigrationFailureAlert(error: error)
    
    // Attempt rollback
    try await manager.rollback()
}
```

### Step 3: Post-Migration Validation

```swift
// Validate data integrity
do {
    let validationResult = try await manager.validateSchema()
    
    if validationResult.isValid {
        print("Post-migration validation passed")
        
        // Update application version
        updateAppVersion(to: "2.0.0")
        
        // Send success notification
        sendValidationSuccessNotification()
        
    } else {
        print("Post-migration validation failed")
        
        // Trigger rollback
        try await manager.rollback()
        
        // Send alert
        sendValidationFailureAlert(errors: validationResult.errors)
    }
} catch {
    print("Validation process failed: \(error)")
}
```

## Best Practices Summary

1. **Always backup before migration**
2. **Test thoroughly in development**
3. **Monitor progress and resources**
4. **Implement proper error handling**
5. **Have a rollback strategy**
6. **Validate results after migration**
7. **Use analytics for monitoring**
8. **Follow security best practices**
9. **Document your migration process**
10. **Train your team on migration procedures**
