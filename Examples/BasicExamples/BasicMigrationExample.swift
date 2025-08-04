import Foundation
import DatabaseMigrationFramework

/// Basic Migration Example
/// This example demonstrates how to perform a simple database migration
/// using the iOS Database Migration Framework.
public class BasicMigrationExample {
    
    private let migrationManager = DatabaseMigrationManager()
    
    public init() {}
    
    /// Perform a basic database migration
    public func performBasicMigration() {
        // Configure migration settings
        let config = MigrationConfiguration()
        config.enableAutomaticMigration = true
        config.enableBackupBeforeMigration = true
        config.enableProgressTracking = true
        config.batchSize = 1000
        
        // Start migration manager
        migrationManager.start(with: config)
        
        // Perform migration
        migrationManager.migrateDatabase { result in
            switch result {
            case .success:
                print("✅ Basic migration completed successfully")
            case .failure(let error):
                print("❌ Basic migration failed: \(error)")
            }
        }
    }
    
    /// Create a simple migration
    public func createSimpleMigration() {
        let migration = DatabaseMigration(
            version: 1,
            description: "Initial database setup",
            sql: """
            CREATE TABLE users (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                email TEXT UNIQUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """
        )
        
        // Execute migration
        migrationManager.executeMigration(migration) { result in
            switch result {
            case .success:
                print("✅ Simple migration executed successfully")
            case .failure(let error):
                print("❌ Simple migration failed: \(error)")
            }
        }
    }
    
    /// Add a new table migration
    public func addTableMigration() {
        let migration = DatabaseMigration(
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
            """
        )
        
        migrationManager.executeMigration(migration) { result in
            switch result {
            case .success:
                print("✅ Table migration executed successfully")
            case .failure(let error):
                print("❌ Table migration failed: \(error)")
            }
        }
    }
}

// MARK: - Usage Example
extension BasicMigrationExample {
    
    /// Example usage of basic migration
    public static func runExample() {
        let example = BasicMigrationExample()
        
        print("🚀 Starting Basic Migration Example")
        
        // Perform basic migration
        example.performBasicMigration()
        
        // Create simple migration
        example.createSimpleMigration()
        
        // Add table migration
        example.addTableMigration()
        
        print("✅ Basic Migration Example completed")
    }
} 