import Foundation
import Logging

/// Analytics tracker for migration operations
public final class MigrationAnalytics {
    
    // MARK: - Properties
    
    private let configuration: MigrationAnalyticsConfiguration
    private let logger: Logger
    private var analyticsData: MigrationAnalyticsData
    
    // MARK: - Initialization
    
    public init(configuration: MigrationAnalyticsConfiguration) {
        self.configuration = configuration
        self.logger = Logger(label: "MigrationAnalytics")
        self.analyticsData = MigrationAnalyticsData()
    }
    
    // MARK: - Public Methods
    
    /// Records successful migration
    /// - Parameter result: Migration result
    public func recordMigrationSuccess(_ result: MigrationResult) {
        logger.info("Recording migration success")
        
        analyticsData.successfulMigrations += 1
        analyticsData.totalMigrationTime += result.duration
        analyticsData.averageMigrationTime = analyticsData.totalMigrationTime / Double(analyticsData.successfulMigrations)
        
        if configuration.enablePerformanceMetrics {
            recordPerformanceMetrics(result)
        }
        
        if configuration.enableAuditLogging {
            recordAuditLog(result, success: true)
        }
    }
    
    /// Records failed migration
    /// - Parameter error: Migration error
    public func recordMigrationFailure(_ error: Error) {
        logger.error("Recording migration failure: \(error.localizedDescription)")
        
        analyticsData.failedMigrations += 1
        analyticsData.lastError = error.localizedDescription
        
        if configuration.enableAuditLogging {
            recordAuditLog(nil, success: false, error: error)
        }
    }
    
    /// Records migration progress
    /// - Parameter progress: Progress information
    public func recordProgress(_ progress: ProgressInfo) {
        if configuration.enablePerformanceMetrics {
            analyticsData.currentProgress = progress
        }
    }
    
    /// Gets analytics data
    /// - Returns: Analytics data with migration statistics
    public func getAnalyticsData() -> MigrationAnalyticsData {
        return analyticsData
    }
    
    /// Resets analytics data
    public func resetAnalytics() {
        analyticsData = MigrationAnalyticsData()
        logger.info("Analytics data reset")
    }
    
    // MARK: - Private Methods
    
    private func recordPerformanceMetrics(_ result: MigrationResult) {
        analyticsData.performanceMetrics.append(
            PerformanceMetric(
                timestamp: Date(),
                duration: result.duration,
                recordsCount: result.recordsCount,
                success: result.success
            )
        )
    }
    
    private func recordAuditLog(_ result: MigrationResult?, success: Bool, error: Error? = nil) {
        let auditEntry = AuditLogEntry(
            timestamp: Date(),
            operation: "migration",
            success: success,
            duration: result?.duration ?? 0,
            error: error?.localizedDescription,
            details: result?.fromVersion ?? "unknown"
        )
        
        analyticsData.auditLog.append(auditEntry)
    }
}

// MARK: - Supporting Types

public struct MigrationAnalyticsConfiguration {
    public let enablePerformanceMetrics: Bool
    public let enableDataIntegrityChecks: Bool
    public let enableAuditLogging: Bool
    
    public init(
        enablePerformanceMetrics: Bool = true,
        enableDataIntegrityChecks: Bool = true,
        enableAuditLogging: Bool = true
    ) {
        self.enablePerformanceMetrics = enablePerformanceMetrics
        self.enableDataIntegrityChecks = enableDataIntegrityChecks
        self.enableAuditLogging = enableAuditLogging
    }
}

public struct MigrationAnalyticsData {
    public var successfulMigrations: Int = 0
    public var failedMigrations: Int = 0
    public var totalMigrationTime: TimeInterval = 0
    public var averageMigrationTime: TimeInterval = 0
    public var lastError: String?
    public var currentProgress: ProgressInfo?
    public var performanceMetrics: [PerformanceMetric] = []
    public var auditLog: [AuditLogEntry] = []
    
    public var successRate: Double {
        let total = successfulMigrations + failedMigrations
        return total > 0 ? Double(successfulMigrations) / Double(total) : 0
    }
}

public struct PerformanceMetric {
    public let timestamp: Date
    public let duration: TimeInterval
    public let recordsCount: Int
    public let success: Bool
}

public struct AuditLogEntry {
    public let timestamp: Date
    public let operation: String
    public let success: Bool
    public let duration: TimeInterval
    public let error: String?
    public let details: String
}
