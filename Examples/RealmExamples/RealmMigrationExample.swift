import Foundation
import RealmSwift
import DatabaseMigrationFramework

/// Realm Migration Example
/// This example demonstrates how to perform Realm database migrations
/// using the iOS Database Migration Framework.
public class RealmMigrationExample {
    
    private let realmMigration = RealmMigrationManager()
    
    public init() {}
    
    /// Perform basic Realm migration
    public func performBasicMigration() {
        let realmConfig = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: User.className()) { oldObject, newObject in
                        newObject!["preferences"] = ["theme": "light"]
                    }
                }
            }
        )
        
        realmMigration.migrate(with: realmConfig) { result in
            switch result {
            case .success:
                print("✅ Basic Realm migration successful")
            case .failure(let error):
                print("❌ Basic Realm migration failed: \(error)")
            }
        }
    }
    
    /// Perform complex Realm migration
    public func performComplexMigration() {
        let realmConfig = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // Add preferences property
                    migration.enumerateObjects(ofType: User.className()) { oldObject, newObject in
                        newObject!["preferences"] = ["theme": "light"]
                    }
                }
                
                if oldSchemaVersion < 3 {
                    // Add posts relationship
                    migration.enumerateObjects(ofType: User.className()) { oldObject, newObject in
                        newObject!["posts"] = List<Post>()
                    }
                }
            }
        )
        
        realmMigration.migrate(with: realmConfig) { result in
            switch result {
            case .success:
                print("✅ Complex Realm migration successful")
            case .failure(let error):
                print("❌ Complex Realm migration failed: \(error)")
            }
        }
    }
    
    /// Create custom migration block
    public func createCustomMigrationBlock() {
        let migrationBlock = realmMigration.createMigrationBlock(from: 1, to: 2)
        
        let realmConfig = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: migrationBlock
        )
        
        realmMigration.migrate(with: realmConfig) { result in
            switch result {
            case .success:
                print("✅ Custom Realm migration successful")
            case .failure(let error):
                print("❌ Custom Realm migration failed: \(error)")
            }
        }
    }
}

// MARK: - Realm Models
public class User: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var preferences: Map<String, String>
    @Persisted var posts: List<Post>
    @Persisted var createdAt: Date
}

public class Post: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var title: String
    @Persisted var content: String?
    @Persisted var user: User?
    @Persisted var createdAt: Date
}

// MARK: - Usage Example
extension RealmMigrationExample {
    
    /// Example usage of Realm migration
    public static func runExample() {
        let example = RealmMigrationExample()
        
        print("🚀 Starting Realm Migration Example")
        
        // Perform basic migration
        example.performBasicMigration()
        
        // Perform complex migration
        example.performComplexMigration()
        
        // Create custom migration block
        example.createCustomMigrationBlock()
        
        print("✅ Realm Migration Example completed")
    }
} 