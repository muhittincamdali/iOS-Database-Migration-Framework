import Foundation
import DatabaseMigrationFramework

/// Advanced Migration Example
/// This example demonstrates complex migration scenarios including
/// incremental migrations, data transformation, and performance optimization.
public class AdvancedMigrationExample {
    
    private let migrationManager = DatabaseMigrationManager()
    private let incrementalMigration = IncrementalMigrationManager()
    private let dataMigration = DataMigrationManager()
    private let performanceManager = PerformanceManager()
    
    public init() {}
    
    /// Perform incremental migration with multiple steps
    public func performIncrementalMigration() {
        let migrationSteps = [
            MigrationStep(version: 1, description: "Create users table") { context in
                try context.executeSQL("""
                    CREATE TABLE users (
                        id INTEGER PRIMARY KEY,
                        first_name TEXT NOT NULL,
                        last_name TEXT NOT NULL,
                        email_address TEXT UNIQUE,
                        registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    );
                    """)
            },
            MigrationStep(version: 2, description: "Add user preferences") { context in
                try context.executeSQL("""
                    CREATE TABLE user_preferences (
                        id INTEGER PRIMARY KEY,
                        user_id INTEGER NOT NULL,
                        theme TEXT DEFAULT 'light',
                        notifications_enabled BOOLEAN DEFAULT 1,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (user_id) REFERENCES users(id)
                    );
                    """)
            },
            MigrationStep(version: 3, description: "Add posts table") { context in
                try context.executeSQL("""
                    CREATE TABLE posts (
                        id INTEGER PRIMARY KEY,
                        user_id INTEGER NOT NULL,
                        title TEXT NOT NULL,
                        content TEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (user_id) REFERENCES users(id)
                    );
                    """)
            },
            MigrationStep(version: 4, description: "Add indexes") { context in
                try context.executeSQL("CREATE INDEX idx_posts_user_id ON posts(user_id);")
                try context.executeSQL("CREATE INDEX idx_preferences_user_id ON user_preferences(user_id);")
            }
        ]
        
        // Start performance monitoring
        performanceManager.startPerformanceMonitoring()
        
        // Execute incremental migration
        incrementalMigration.migrateIncremental(steps: migrationSteps) { progress in
            print("Migration progress: \(progress.percentage)%")
            print("Current step: \(progress.currentStep)")
            print("Total steps: \(progress.totalSteps)")
        } completion: { result in
            performanceManager.stopPerformanceMonitoring()
            
            switch result {
            case .success:
                print("✅ Incremental migration successful")
                let metrics = performanceManager.getPerformanceMetrics()
                print("Migration time: \(metrics.migrationTime)s")
                print("Memory usage: \(metrics.memoryUsage) bytes")
            case .failure(let error):
                print("❌ Incremental migration failed: \(error)")
            }
        }
    }
    
    /// Perform data transformation migration
    public func performDataTransformation() {
        let dataTransformation = DataTransformation()
        
        // Transform user data
        dataTransformation.transformTable("users") { oldData, newData in
            for row in oldData {
                let newRow = newData.createRow()
                newRow["id"] = row["id"]
                newRow["name"] = row["first_name"] + " " + row["last_name"]
                newRow["email"] = row["email_address"]
                newRow["created_at"] = row["registration_date"]
            }
        }
        
        // Execute data migration
        dataMigration.migrateData(transformation: dataTransformation) { result in
            switch result {
            case .success(let migrationResult):
                print("✅ Data transformation successful")
                print("Records migrated: \(migrationResult.recordsMigrated)")
                print("Migration time: \(migrationResult.migrationTime)s")
            case .failure(let error):
                print("❌ Data transformation failed: \(error)")
            }
        }
    }
    
    /// Perform large dataset migration with batch processing
    public func performLargeDatasetMigration() {
        let largeDatasetMigration = LargeDatasetMigrationManager()
        
        // Configure batch processing
        let batchConfig = BatchProcessingConfiguration()
        batchConfig.batchSize = 1000
        batchConfig.maxConcurrentBatches = 4
        batchConfig.memoryLimit = 100 * 1024 * 1024 // 100MB
        
        // Migrate large dataset
        largeDatasetMigration.migrateLargeDataset(
            sourceTable: "users",
            targetTable: "users_v2",
            batchConfig: batchConfig
        ) { progress in
            print("Migration progress: \(progress.percentage)%")
            print("Records processed: \(progress.recordsProcessed)")
            print("Current batch: \(progress.currentBatch)")
            print("Total batches: \(progress.totalBatches)")
        } completion: { result in
            switch result {
            case .success(let migrationResult):
                print("✅ Large dataset migration successful")
                print("Total records: \(migrationResult.totalRecords)")
                print("Migration time: \(migrationResult.migrationTime)s")
                print("Average speed: \(migrationResult.recordsPerSecond) records/s")
            case .failure(let error):
                print("❌ Large dataset migration failed: \(error)")
            }
        }
    }
}

// MARK: - Usage Example
extension AdvancedMigrationExample {
    
    /// Example usage of advanced migration
    public static func runExample() {
        let example = AdvancedMigrationExample()
        
        print("🚀 Starting Advanced Migration Example")
        
        // Perform incremental migration
        example.performIncrementalMigration()
        
        // Perform data transformation
        example.performDataTransformation()
        
        // Perform large dataset migration
        example.performLargeDatasetMigration()
        
        print("✅ Advanced Migration Example completed")
    }
} 