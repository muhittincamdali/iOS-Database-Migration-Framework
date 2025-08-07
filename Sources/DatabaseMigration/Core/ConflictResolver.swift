import Foundation
import CoreData

/// Resolves conflicts during database migrations
public class ConflictResolver {
    
    // MARK: - Properties
    
    private var resolutionStrategies: [String: ConflictResolutionStrategy] = [:]
    private var conflictLog: [MigrationConflict] = []
    
    // MARK: - Initialization
    
    public init() {
        setupDefaultStrategies()
    }
    
    // MARK: - Public Methods
    
    /// Register a custom resolution strategy for a specific conflict type
    /// - Parameters:
    ///   - strategy: The resolution strategy to use
    ///   - forConflictType: Type of conflict this strategy handles
    public func registerStrategy(_ strategy: ConflictResolutionStrategy, forConflictType conflictType: String) {
        resolutionStrategies[conflictType] = strategy
    }
    
    /// Resolve a migration conflict
    /// - Parameter conflict: The conflict to resolve
    /// - Returns: Resolution result
    public func resolveConflict(_ conflict: MigrationConflict) -> ConflictResolutionResult {
        // Log the conflict
        conflictLog.append(conflict)
        
        // Find appropriate strategy
        guard let strategy = resolutionStrategies[conflict.type] else {
            return ConflictResolutionResult(
                success: false,
                resolution: .unresolved,
                error: ConflictResolutionError.noStrategyFound(conflict.type)
            )
        }
        
        // Apply strategy
        do {
            let resolution = try strategy.resolve(conflict)
            return ConflictResolutionResult(
                success: true,
                resolution: resolution,
                error: nil
            )
        } catch {
            return ConflictResolutionResult(
                success: false,
                resolution: .unresolved,
                error: error
            )
        }
    }
    
    /// Resolve multiple conflicts in batch
    /// - Parameter conflicts: Array of conflicts to resolve
    /// - Returns: Array of resolution results
    public func resolveConflicts(_ conflicts: [MigrationConflict]) -> [ConflictResolutionResult] {
        return conflicts.map { resolveConflict($0) }
    }
    
    /// Get conflict resolution statistics
    /// - Returns: Statistics about resolved conflicts
    public func getConflictStatistics() -> ConflictStatistics {
        let totalConflicts = conflictLog.count
        let resolvedConflicts = conflictLog.filter { conflict in
            let result = resolveConflict(conflict)
            return result.success
        }.count
        
        let conflictTypes = Dictionary(grouping: conflictLog, by: { $0.type })
            .mapValues { $0.count }
        
        return ConflictStatistics(
            totalConflicts: totalConflicts,
            resolvedConflicts: resolvedConflicts,
            resolutionRate: totalConflicts > 0 ? Double(resolvedConflicts) / Double(totalConflicts) : 0,
            conflictTypes: conflictTypes
        )
    }
    
    /// Clear conflict log
    public func clearConflictLog() {
        conflictLog.removeAll()
    }
    
    /// Get all recorded conflicts
    /// - Returns: Array of all recorded conflicts
    public func getAllConflicts() -> [MigrationConflict] {
        return conflictLog
    }
    
    // MARK: - Private Methods
    
    private func setupDefaultStrategies() {
        // Default strategy for duplicate key conflicts
        registerStrategy(DuplicateKeyResolutionStrategy(), forConflictType: "duplicate_key")
        
        // Default strategy for data type conflicts
        registerStrategy(DataTypeResolutionStrategy(), forConflictType: "data_type")
        
        // Default strategy for constraint violations
        registerStrategy(ConstraintViolationResolutionStrategy(), forConflictType: "constraint_violation")
        
        // Default strategy for foreign key conflicts
        registerStrategy(ForeignKeyResolutionStrategy(), forConflictType: "foreign_key")
    }
}

// MARK: - Supporting Types

public struct MigrationConflict {
    public let id: UUID
    public let type: String
    public let description: String
    public let entityName: String?
    public let propertyName: String?
    public let oldValue: Any?
    public let newValue: Any?
    public let timestamp: Date
    public let severity: ConflictSeverity
    
    public init(
        type: String,
        description: String,
        entityName: String? = nil,
        propertyName: String? = nil,
        oldValue: Any? = nil,
        newValue: Any? = nil,
        severity: ConflictSeverity = .medium
    ) {
        self.id = UUID()
        self.type = type
        self.description = description
        self.entityName = entityName
        self.propertyName = propertyName
        self.oldValue = oldValue
        self.newValue = newValue
        self.timestamp = Date()
        self.severity = severity
    }
}

public enum ConflictSeverity: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    public var priority: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
}

public enum ConflictResolution {
    case resolved(Any?)
    case ignored
    case manual
    case unresolved
}

public struct ConflictResolutionResult {
    public let success: Bool
    public let resolution: ConflictResolution
    public let error: Error?
    
    public init(success: Bool, resolution: ConflictResolution, error: Error?) {
        self.success = success
        self.resolution = resolution
        self.error = error
    }
}

public struct ConflictStatistics {
    public let totalConflicts: Int
    public let resolvedConflicts: Int
    public let resolutionRate: Double
    public let conflictTypes: [String: Int]
    
    public var formattedReport: String {
        var report = "📊 Conflict Resolution Report
"
        report += "==========================
"
        report += "Total Conflicts: \(totalConflicts)
"
        report += "Resolved: \(resolvedConflicts)
"
        report += "Resolution Rate: \(String(format: "%.1f", resolutionRate * 100))%

"
        
        report += "Conflict Types:
"
        for (type, count) in conflictTypes.sorted(by: { $0.value > $1.value }) {
            report += "  🔹 \(type): \(count)
"
        }
        
        return report
    }
}

// MARK: - Resolution Strategies

public protocol ConflictResolutionStrategy {
    func resolve(_ conflict: MigrationConflict) throws -> ConflictResolution
}

public class DuplicateKeyResolutionStrategy: ConflictResolutionStrategy {
    public func resolve(_ conflict: MigrationConflict) throws -> ConflictResolution {
        // For duplicate keys, use the newer value
        return .resolved(conflict.newValue)
    }
}

public class DataTypeResolutionStrategy: ConflictResolutionStrategy {
    public func resolve(_ conflict: MigrationConflict) throws -> ConflictResolution {
        // For data type conflicts, try to convert the value
        guard let oldValue = conflict.oldValue, let newValue = conflict.newValue else {
            return .unresolved
        }
        
        // Attempt type conversion
        if let convertedValue = try? convertValue(newValue, toTypeOf: oldValue) {
            return .resolved(convertedValue)
        }
        
        return .manual
    }
    
    private func convertValue(_ value: Any, toTypeOf target: Any) throws -> Any {
        // Implement type conversion logic
        return value
    }
}

public class ConstraintViolationResolutionStrategy: ConflictResolutionStrategy {
    public func resolve(_ conflict: MigrationConflict) throws -> ConflictResolution {
        // For constraint violations, try to fix the data
        return .manual
    }
}

public class ForeignKeyResolutionStrategy: ConflictResolutionStrategy {
    public func resolve(_ conflict: MigrationConflict) throws -> ConflictResolution {
        // For foreign key conflicts, try to find or create the referenced entity
        return .manual
    }
}

public enum ConflictResolutionError: Error, LocalizedError {
    case noStrategyFound(String)
    case resolutionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .noStrategyFound(let type):
            return "No resolution strategy found for conflict type: \(type)"
        case .resolutionFailed(let reason):
            return "Conflict resolution failed: \(reason)"
        }
    }
}
