import Foundation
import CoreData
import DatabaseMigrationFramework

/// Core Data Migration Example
/// This example demonstrates how to perform Core Data migrations
/// using the iOS Database Migration Framework.
public class CoreDataMigrationExample {
    
    private let coreDataMigration = CoreDataMigrationManager()
    
    public init() {}
    
    /// Perform Core Data migration
    public func performCoreDataMigration() {
        // Configure Core Data migration
        let migrationConfig = CoreDataMigrationConfiguration()
        migrationConfig.enableAutomaticMigration = true
        migrationConfig.enableLightweightMigration = true
        migrationConfig.enableHeavyweightMigration = true
        migrationConfig.backupBeforeMigration = true
        
        // Perform Core Data migration
        coreDataMigration.migrate(
            from: "UserModel_v1",
            to: "UserModel_v2",
            configuration: migrationConfig
        ) { result in
            switch result {
            case .success(let migrationResult):
                print("✅ Core Data migration successful")
                print("Migrated records: \(migrationResult.migratedRecords)")
                print("Migration time: \(migrationResult.migrationTime)s")
            case .failure(let error):
                print("❌ Core Data migration failed: \(error)")
            }
        }
    }
    
    /// Perform lightweight migration
    public func performLightweightMigration() {
        let config = CoreDataMigrationConfiguration()
        config.enableLightweightMigration = true
        config.backupBeforeMigration = true
        
        coreDataMigration.migrate(
            from: "UserModel_v1",
            to: "UserModel_v2",
            configuration: config
        ) { result in
            switch result {
            case .success:
                print("✅ Lightweight migration successful")
            case .failure(let error):
                print("❌ Lightweight migration failed: \(error)")
            }
        }
    }
    
    /// Perform heavyweight migration with custom mapping
    public func performHeavyweightMigration() {
        let config = CoreDataMigrationConfiguration()
        config.enableHeavyweightMigration = true
        config.allowInferringMappingModel = true
        config.backupBeforeMigration = true
        
        coreDataMigration.migrate(
            from: "UserModel_v1",
            to: "UserModel_v3",
            configuration: config
        ) { result in
            switch result {
            case .success:
                print("✅ Heavyweight migration successful")
            case .failure(let error):
                print("❌ Heavyweight migration failed: \(error)")
            }
        }
    }
    
    /// Check if migration is required
    public func checkMigrationRequired() {
        let modelVersionManager = CoreDataModelVersionManager()
        
        if modelVersionManager.isMigrationRequired() {
            print("⚠️ Migration is required")
            let currentVersion = modelVersionManager.getCurrentModelVersion()
            let availableVersions = modelVersionManager.getAvailableModelVersions()
            
            print("Current version: \(currentVersion)")
            print("Available versions: \(availableVersions)")
        } else {
            print("✅ No migration required")
        }
    }
}

// MARK: - Usage Example
extension CoreDataMigrationExample {
    
    /// Example usage of Core Data migration
    public static func runExample() {
        let example = CoreDataMigrationExample()
        
        print("🚀 Starting Core Data Migration Example")
        
        // Check if migration is required
        example.checkMigrationRequired()
        
        // Perform Core Data migration
        example.performCoreDataMigration()
        
        // Perform lightweight migration
        example.performLightweightMigration()
        
        // Perform heavyweight migration
        example.performHeavyweightMigration()
        
        print("✅ Core Data Migration Example completed")
    }
} 