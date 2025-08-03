# Advanced Example

## Overview

This example demonstrates advanced features of the iOS Database Migration Framework including custom policies, analytics, and complex migration scenarios.

## Advanced Configuration

### Custom Analytics Configuration

```swift
import DatabaseMigration

let analyticsConfig = MigrationAnalyticsConfiguration(
    enablePerformanceMetrics: true,
    enableDataIntegrityChecks: true,
    enableAuditLogging: true
)

let analytics = MigrationAnalytics(configuration: analyticsConfig)
```

### Advanced Migration Configuration

```swift
let config = MigrationConfiguration(
    currentVersion: "1.0.0",
    targetVersion: "2.0.0",
    enableRollback: true,
    enableAnalytics: true,
    enableBackup: true,
    logLevel: .debug
)
```

## Advanced Migration with Custom Policies

```swift
// Custom migration policy for data transformation
let dataTransformationPolicy = CustomMigrationPolicy { context in
    // Complex data transformation logic
    let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "User")
    
    do {
        let users = try context.fetch(fetchRequest)
        
        for user in users {
            // Transform email addresses
            if let email = user.value(forKey: "email") as? String {
                let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
                user.setValue(normalizedEmail, forKey: "email")
            }
            
            // Add default values for new fields
            if user.value(forKey: "isActive") == nil {
                user.setValue(true, forKey: "isActive")
            }
            
            if user.value(forKey: "createdAt") == nil {
                user.setValue(Date(), forKey: "createdAt")
            }
            
            // Complex data validation
            if let age = user.value(forKey: "age") as? Int {
                if age < 0 || age > 150 {
                    user.setValue(18, forKey: "age") // Default age
                }
            }
        }
        
        try context.save()
    } catch {
        throw error
    }
}
```

## Multi-Step Migration

```swift
class AdvancedMigrationExample {
    
    private let manager: MigrationManager
    private let analytics: MigrationAnalytics
    
    init() {
        let config = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        
        self.manager = MigrationManager(configuration: config)
        
        let analyticsConfig = MigrationAnalyticsConfiguration(
            enablePerformanceMetrics: true,
            enableDataIntegrityChecks: true,
            enableAuditLogging: true
        )
        
        self.analytics = MigrationAnalytics(configuration: analyticsConfig)
    }
    
    func performAdvancedMigration() async {
        // Step 1: Pre-migration validation
        do {
            let validationResult = try await manager.validateSchema()
            
            if !validationResult.isValid {
                print("Pre-migration validation failed: \(validationResult.errors)")
                return
            }
            
            print("Pre-migration validation passed")
            
        } catch {
            print("Pre-migration validation error: \(error)")
            return
        }
        
        // Step 2: Create backup
        do {
            try await createBackup()
            print("Backup created successfully")
        } catch {
            print("Backup creation failed: \(error)")
            return
        }
        
        // Step 3: Perform migration with detailed progress tracking
        let progressHandler: ProgressHandler = { progress in
            DispatchQueue.main.async {
                self.updateProgressUI(progress: progress)
                self.logProgress(progress: progress)
            }
        }
        
        do {
            let result = try await manager.migrate(progressHandler: progressHandler)
            print("Migration completed successfully")
            
            // Step 4: Post-migration validation
            let postValidationResult = try await manager.validateSchema()
            
            if postValidationResult.isValid {
                print("Post-migration validation passed")
                
                // Step 5: Analyze results
                self.analyzeMigrationResults(result: result)
                
            } else {
                print("Post-migration validation failed: \(postValidationResult.errors)")
                
                // Step 6: Rollback if validation fails
                try await self.performRollback()
            }
            
        } catch {
            print("Migration failed: \(error)")
            
            // Rollback on failure
            try await self.performRollback()
        }
    }
    
    private func createBackup() async throws {
        // Implementation for creating backup
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate backup
    }
    
    private func updateProgressUI(progress: ProgressInfo) {
        // Update UI with progress
        print("UI Update: \(progress.percentage)% - \(progress.stage)")
    }
    
    private func logProgress(progress: ProgressInfo) {
        // Log progress for monitoring
        print("Log: Migration progress \(progress.percentage)% at \(Date())")
    }
    
    private func analyzeMigrationResults(result: MigrationResult) {
        let analyticsData = analytics.getAnalyticsData()
        
        print("=== Migration Analysis ===")
        print("Duration: \(result.duration) seconds")
        print("Records processed: \(result.recordsCount)")
        print("Success rate: \(analyticsData?.successRate ?? 0)")
        print("Average time: \(analyticsData?.averageMigrationTime ?? 0)")
        
        // Analyze performance metrics
        if let metrics = analyticsData?.performanceMetrics {
            print("Performance metrics: \(metrics.count) entries")
            
            let avgDuration = metrics.map { $0.duration }.reduce(0, +) / Double(metrics.count)
            print("Average duration: \(avgDuration) seconds")
        }
        
        // Analyze audit log
        if let auditLog = analyticsData?.auditLog {
            print("Audit log entries: \(auditLog.count)")
            
            let successCount = auditLog.filter { $0.success }.count
            let failureCount = auditLog.filter { !$0.success }.count
            
            print("Successful operations: \(successCount)")
            print("Failed operations: \(failureCount)")
        }
    }
    
    private func performRollback() async throws {
        print("Performing rollback...")
        
        do {
            let rollbackResult = try await manager.rollback()
            print("Rollback successful to: \(rollbackResult.targetVersion)")
        } catch {
            print("Rollback failed: \(error)")
            throw error
        }
    }
}
```

## Performance Monitoring

```swift
class PerformanceMonitor {
    
    private let analytics: MigrationAnalytics
    
    init() {
        let config = MigrationAnalyticsConfiguration(
            enablePerformanceMetrics: true,
            enableDataIntegrityChecks: true,
            enableAuditLogging: true
        )
        
        self.analytics = MigrationAnalytics(configuration: config)
    }
    
    func monitorMigration() {
        // Monitor real-time performance
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let data = self.analytics.getAnalyticsData()
            
            if let currentProgress = data?.currentProgress {
                print("Current progress: \(currentProgress.percentage)%")
            }
            
            if let avgTime = data?.averageMigrationTime {
                print("Average migration time: \(avgTime) seconds")
            }
        }
    }
    
    func generatePerformanceReport() {
        let data = analytics.getAnalyticsData()
        
        print("=== Performance Report ===")
        print("Total migrations: \(data?.successfulMigrations ?? 0)")
        print("Failed migrations: \(data?.failedMigrations ?? 0)")
        print("Success rate: \(data?.successRate ?? 0)")
        print("Total migration time: \(data?.totalMigrationTime ?? 0)")
        print("Average migration time: \(data?.averageMigrationTime ?? 0)")
        
        // Detailed performance analysis
        if let metrics = data?.performanceMetrics {
            let sortedMetrics = metrics.sorted { $0.duration < $1.duration }
            
            print("Fastest migration: \(sortedMetrics.first?.duration ?? 0) seconds")
            print("Slowest migration: \(sortedMetrics.last?.duration ?? 0) seconds")
            
            let recentMetrics = sortedMetrics.suffix(5)
            let recentAvg = recentMetrics.map { $0.duration }.reduce(0, +) / Double(recentMetrics.count)
            print("Recent average: \(recentAvg) seconds")
        }
    }
}
```

## Error Recovery

```swift
class ErrorRecoveryExample {
    
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
    
    func performMigrationWithRecovery() async {
        do {
            let result = try await manager.migrate()
            print("Migration successful")
            
        } catch MigrationError.invalidCurrentVersion {
            print("Recovering from invalid version error...")
            try await recoverFromInvalidVersion()
            
        } catch MigrationError.schemaValidationFailed(let errors) {
            print("Recovering from schema validation failure...")
            try await recoverFromSchemaValidationFailure(errors: errors)
            
        } catch MigrationError.backupCreationFailed {
            print("Recovering from backup creation failure...")
            try await recoverFromBackupFailure()
            
        } catch {
            print("Recovering from unexpected error: \(error)")
            try await recoverFromUnexpectedError(error)
        }
    }
    
    private func recoverFromInvalidVersion() async throws {
        // Implement recovery logic for invalid version
        print("Attempting to fix version information...")
        
        // Retry migration with corrected version
        let correctedConfig = MigrationConfiguration(
            currentVersion: "1.0.0", // Corrected version
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        
        let correctedManager = MigrationManager(configuration: correctedConfig)
        let result = try await correctedManager.migrate()
        print("Recovery successful: \(result)")
    }
    
    private func recoverFromSchemaValidationFailure(errors: [String]) async throws {
        // Implement recovery logic for schema validation failure
        print("Attempting to fix schema validation issues...")
        
        // Log errors for analysis
        for error in errors {
            print("Schema error: \(error)")
        }
        
        // Attempt to fix schema issues
        try await fixSchemaIssues(errors: errors)
        
        // Retry migration
        let result = try await manager.migrate()
        print("Recovery successful: \(result)")
    }
    
    private func recoverFromBackupFailure() async throws {
        // Implement recovery logic for backup failure
        print("Attempting to create backup with alternative method...")
        
        // Try alternative backup method
        try await createAlternativeBackup()
        
        // Proceed with migration
        let result = try await manager.migrate()
        print("Recovery successful: \(result)")
    }
    
    private func recoverFromUnexpectedError(_ error: Error) async throws {
        // Implement recovery logic for unexpected errors
        print("Attempting to recover from unexpected error...")
        
        // Log error for analysis
        print("Unexpected error: \(error)")
        
        // Attempt rollback
        do {
            let rollbackResult = try await manager.rollback()
            print("Rollback successful: \(rollbackResult)")
        } catch {
            print("Rollback failed: \(error)")
            throw error
        }
    }
    
    private func fixSchemaIssues(errors: [String]) async throws {
        // Implementation for fixing schema issues
        print("Fixing schema issues...")
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate fix
    }
    
    private func createAlternativeBackup() async throws {
        // Implementation for alternative backup method
        print("Creating alternative backup...")
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate backup
    }
}
```

## Testing Advanced Features

```swift
import XCTest
@testable import DatabaseMigration

class AdvancedMigrationTests: XCTestCase {
    
    var manager: MigrationManager!
    var analytics: MigrationAnalytics!
    
    override func setUp() {
        super.setUp()
        
        let config = MigrationConfiguration(
            currentVersion: "1.0.0",
            targetVersion: "2.0.0",
            enableRollback: true,
            enableAnalytics: true
        )
        
        manager = MigrationManager(configuration: config)
        
        let analyticsConfig = MigrationAnalyticsConfiguration(
            enablePerformanceMetrics: true,
            enableDataIntegrityChecks: true,
            enableAuditLogging: true
        )
        
        analytics = MigrationAnalytics(configuration: analyticsConfig)
    }
    
    func testAdvancedMigration() async throws {
        let progressHandler: ProgressHandler = { progress in
            XCTAssertGreaterThanOrEqual(progress.percentage, 0)
            XCTAssertLessThanOrEqual(progress.percentage, 100)
        }
        
        let result = try await manager.migrate(progressHandler: progressHandler)
        XCTAssertTrue(result.success)
    }
    
    func testAnalyticsRecording() {
        let result = MigrationResult(
            success: true,
            fromVersion: "1.0.0",
            toVersion: "2.0.0",
            duration: 1.5,
            recordsCount: 100,
            errors: []
        )
        
        analytics.recordMigrationSuccess(result)
        
        let data = analytics.getAnalyticsData()
        XCTAssertEqual(data.successfulMigrations, 1)
        XCTAssertEqual(data.successRate, 1.0)
    }
    
    func testErrorRecovery() async throws {
        // Test error recovery scenarios
        let error = MigrationError.invalidCurrentVersion
        analytics.recordMigrationFailure(error)
        
        let data = analytics.getAnalyticsData()
        XCTAssertEqual(data.failedMigrations, 1)
        XCTAssertEqual(data.successRate, 0.0)
    }
}
```

## Best Practices for Advanced Usage

1. **Implement comprehensive error recovery**
2. **Use detailed progress tracking**
3. **Monitor performance metrics**
4. **Implement custom migration policies**
5. **Use analytics for insights**
6. **Test all error scenarios**
7. **Document recovery procedures**
8. **Monitor system resources**
9. **Implement proper logging**
10. **Have fallback strategies**
