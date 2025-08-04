import Foundation
import DatabaseMigrationFramework

/// SQLite Migration Example
/// This example demonstrates how to perform SQLite database migrations
/// using the iOS Database Migration Framework.
public class SQLiteMigrationExample {
    
    private let sqliteMigration: SQLiteMigrationManager
    
    public init(databasePath: String = "example.sqlite") {
        self.sqliteMigration = SQLiteMigrationManager(databasePath: databasePath)
    }
    
    /// Perform basic SQLite migration
    public func performBasicMigration() {
        let migration = SQLiteMigration(
            version: 1,
            description: "Create users table",
            sql: """
            CREATE TABLE users (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                email TEXT UNIQUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """,
            rollbackSQL: "DROP TABLE users;"
        )
        
        sqliteMigration.executeMigration(migration) { result in
            switch result {
            case .success:
                print("✅ Basic SQLite migration successful")
            case .failure(let error):
                print("❌ Basic SQLite migration failed: \(error)")
            }
        }
    }
    
    /// Perform multiple migrations
    public func performMultipleMigrations() {
        let migrations = [
            SQLiteMigration(
                version: 1,
                description: "Create users table",
                sql: "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE);"
            ),
            SQLiteMigration(
                version: 2,
                description: "Add email column",
                sql: "ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT 0;"
            ),
            SQLiteMigration(
                version: 3,
                description: "Add created_at column",
                sql: "ALTER TABLE users ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;"
            )
        ]
        
        sqliteMigration.executeMigrations(migrations) { result in
            switch result {
            case .success:
                print("✅ Multiple SQLite migrations successful")
            case .failure(let error):
                print("❌ Multiple SQLite migrations failed: \(error)")
            }
        }
    }
    
    /// Perform complex migration with foreign keys
    public func performComplexMigration() {
        let migration = SQLiteMigration(
            version: 4,
            description: "Add user preferences and posts tables",
            sql: """
            CREATE TABLE user_preferences (
                id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                theme TEXT DEFAULT 'light',
                notifications_enabled BOOLEAN DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            );
            
            CREATE TABLE posts (
                id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                content TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            );
            
            CREATE INDEX idx_posts_user_id ON posts(user_id);
            CREATE INDEX idx_preferences_user_id ON user_preferences(user_id);
            """,
            rollbackSQL: """
            DROP TABLE posts;
            DROP TABLE user_preferences;
            """
        )
        
        sqliteMigration.executeMigration(migration) { result in
            switch result {
            case .success:
                print("✅ Complex SQLite migration successful")
            case .failure(let error):
                print("❌ Complex SQLite migration failed: \(error)")
            }
        }
    }
    
    /// Rollback to previous version
    public func rollbackToVersion(_ version: Int) {
        sqliteMigration.rollbackToVersion(version) { result in
            switch result {
            case .success:
                print("✅ Rollback to version \(version) successful")
            case .failure(let error):
                print("❌ Rollback to version \(version) failed: \(error)")
            }
        }
    }
}

// MARK: - Usage Example
extension SQLiteMigrationExample {
    
    /// Example usage of SQLite migration
    public static func runExample() {
        let example = SQLiteMigrationExample()
        
        print("🚀 Starting SQLite Migration Example")
        
        // Perform basic migration
        example.performBasicMigration()
        
        // Perform multiple migrations
        example.performMultipleMigrations()
        
        // Perform complex migration
        example.performComplexMigration()
        
        // Rollback example (commented out for safety)
        // example.rollbackToVersion(2)
        
        print("✅ SQLite Migration Example completed")
    }
} 