import Foundation
import DatabaseMigrationFramework

/// Performance Optimization Example
/// This example demonstrates performance optimization techniques
/// for database migrations using the iOS Database Migration Framework.
public class PerformanceOptimizationExample {
    
    private let performanceManager = PerformanceManager()
    private let largeDatasetMigration = LargeDatasetMigrationManager()
    private let backgroundMigration = BackgroundMigrationManager()
    
    public init() {}
    
    /// Optimize migration with batch processing
    public func optimizeWithBatchProcessing() {
        // Configure batch processing
        let batchConfig = BatchProcessingConfiguration()
        batchConfig.batchSize = 1000
        batchConfig.maxConcurrentBatches = 4
        batchConfig.memoryLimit = 100 * 1024 * 1024 // 100MB
        
        // Start performance monitoring
        performanceManager.startPerformanceMonitoring()
        
        // Perform optimized migration
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
            performanceManager.stopPerformanceMonitoring()
            
            switch result {
            case .success(let migrationResult):
                print("✅ Optimized migration successful")
                print("Total records: \(migrationResult.totalRecords)")
                print("Migration time: \(migrationResult.migrationTime)s")
                print("Average speed: \(migrationResult.recordsPerSecond) records/s")
                
                let metrics = performanceManager.getPerformanceMetrics()
                print("Memory usage: \(metrics.memoryUsage) bytes")
                print("CPU usage: \(metrics.cpuUsage)%")
            case .failure(let error):
                print("❌ Optimized migration failed: \(error)")
            }
        }
    }
    
    /// Perform background migration
    public func performBackgroundMigration() {
        // Configure background migration
        let backgroundConfig = BackgroundMigrationConfiguration()
        backgroundConfig.priority = .background
        backgroundConfig.requiresNetworkConnectivity = false
        backgroundConfig.allowsCellularAccess = false
        backgroundConfig.maxRetryAttempts = 3
        
        // Start background migration
        backgroundMigration.startBackgroundMigration(
            migration: createSampleMigration(),
            configuration: backgroundConfig
        ) { result in
            switch result {
            case .success:
                print("✅ Background migration completed")
            case .failure(let error):
                print("❌ Background migration failed: \(error)")
            }
        }
    }
    
    /// Monitor performance metrics
    public func monitorPerformanceMetrics() {
        performanceManager.startPerformanceMonitoring()
        
        // Simulate migration work
        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate migration processing
            for i in 1...100 {
                Thread.sleep(forTimeInterval: 0.1)
                
                if i % 10 == 0 {
                    let metrics = performanceManager.getPerformanceMetrics()
                    print("Progress: \(i)%, Memory: \(metrics.memoryUsage) bytes, CPU: \(metrics.cpuUsage)%")
                }
            }
            
            performanceManager.stopPerformanceMonitoring()
            
            let finalMetrics = performanceManager.getPerformanceMetrics()
            print("Final metrics:")
            print("- Migration time: \(finalMetrics.migrationTime)s")
            print("- Memory usage: \(finalMetrics.memoryUsage) bytes")
            print("- CPU usage: \(finalMetrics.cpuUsage)%")
            print("- Disk usage: \(finalMetrics.diskUsage) bytes")
        }
    }
    
    /// Optimize memory usage
    public func optimizeMemoryUsage() {
        let config = MigrationConfiguration()
        config.memoryLimit = 50 * 1024 * 1024 // 50MB
        config.batchSize = 500
        config.maxConcurrentOperations = 2
        
        let migrationManager = DatabaseMigrationManager()
        migrationManager.configure(config)
        
        performanceManager.startPerformanceMonitoring()
        
        migrationManager.migrateDatabase { result in
            performanceManager.stopPerformanceMonitoring()
            
            let metrics = performanceManager.getPerformanceMetrics()
            print("Memory-optimized migration completed")
            print("Memory usage: \(metrics.memoryUsage) bytes")
            print("Migration time: \(metrics.migrationTime)s")
        }
    }
    
    /// Create sample migration for background processing
    private func createSampleMigration() -> DatabaseMigration {
        return DatabaseMigration(
            version: 1,
            description: "Sample background migration",
            sql: """
            CREATE TABLE IF NOT EXISTS sample_data (
                id INTEGER PRIMARY KEY,
                data TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """
        )
    }
}

// MARK: - Usage Example
extension PerformanceOptimizationExample {
    
    /// Example usage of performance optimization
    public static func runExample() {
        let example = PerformanceOptimizationExample()
        
        print("🚀 Starting Performance Optimization Example")
        
        // Optimize with batch processing
        example.optimizeWithBatchProcessing()
        
        // Perform background migration
        example.performBackgroundMigration()
        
        // Monitor performance metrics
        example.monitorPerformanceMetrics()
        
        // Optimize memory usage
        example.optimizeMemoryUsage()
        
        print("✅ Performance Optimization Example completed")
    }
} 