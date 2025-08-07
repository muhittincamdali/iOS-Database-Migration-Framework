import Foundation
import CoreData

/// Performance monitoring and optimization utilities for database migrations
public class PerformanceMonitor {
    
    // MARK: - Properties
    
    private var startTime: Date?
    private var metrics: [String: TimeInterval] = [:]
    private var memoryUsage: [String: Int64] = [:]
    private var operationCounts: [String: Int] = [:]
    
    // MARK: - Singleton
    
    public static let shared = PerformanceMonitor()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Start monitoring a migration operation
    /// - Parameter operationName: Name of the operation to monitor
    public func startMonitoring(operationName: String) {
        startTime = Date()
        metrics[operationName] = 0
        memoryUsage[operationName] = getCurrentMemoryUsage()
        operationCounts[operationName] = 0
    }
    
    /// End monitoring and record metrics
    /// - Parameter operationName: Name of the operation
    /// - Returns: Performance metrics for the operation
    @discardableResult
    public func endMonitoring(operationName: String) -> MigrationPerformanceMetrics {
        guard let start = startTime else {
            return MigrationPerformanceMetrics(duration: 0, memoryUsage: 0, operations: 0)
        }
        
        let duration = Date().timeIntervalSince(start)
        let finalMemoryUsage = getCurrentMemoryUsage()
        let operations = operationCounts[operationName] ?? 0
        
        metrics[operationName] = duration
        memoryUsage[operationName] = finalMemoryUsage
        
        return MigrationPerformanceMetrics(
            duration: duration,
            memoryUsage: finalMemoryUsage,
            operations: operations
        )
    }
    
    /// Record an operation count
    /// - Parameters:
    ///   - operationName: Name of the operation
    ///   - count: Number of operations performed
    public func recordOperation(operationName: String, count: Int = 1) {
        operationCounts[operationName, default: 0] += count
    }
    
    /// Get performance report for all monitored operations
    /// - Returns: Comprehensive performance report
    public func getPerformanceReport() -> PerformanceReport {
        return PerformanceReport(
            metrics: metrics,
            memoryUsage: memoryUsage,
            operationCounts: operationCounts,
            totalDuration: metrics.values.reduce(0, +),
            averageMemoryUsage: memoryUsage.values.isEmpty ? 0 : memoryUsage.values.reduce(0, +) / Int64(memoryUsage.count)
        )
    }
    
    /// Clear all performance data
    public func clearMetrics() {
        metrics.removeAll()
        memoryUsage.removeAll()
        operationCounts.removeAll()
        startTime = nil
    }
    
    // MARK: - Private Methods
    
    private func getCurrentMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        } else {
            return 0
        }
    }
}

// MARK: - Supporting Types

public struct MigrationPerformanceMetrics {
    public let duration: TimeInterval
    public let memoryUsage: Int64
    public let operations: Int
    
    public var operationsPerSecond: Double {
        return duration > 0 ? Double(operations) / duration : 0
    }
    
    public var memoryUsageMB: Double {
        return Double(memoryUsage) / (1024 * 1024)
    }
}

public struct PerformanceReport {
    public let metrics: [String: TimeInterval]
    public let memoryUsage: [String: Int64]
    public let operationCounts: [String: Int]
    public let totalDuration: TimeInterval
    public let averageMemoryUsage: Int64
    
    public var formattedReport: String {
        var report = "📊 Performance Report
"
        report += "==================
"
        report += "Total Duration: \(String(format: "%.2f", totalDuration))s
"
        report += "Average Memory Usage: \(String(format: "%.2f", Double(averageMemoryUsage) / (1024 * 1024)))MB

"
        
        for (operation, duration) in metrics {
            let memory = memoryUsage[operation] ?? 0
            let operations = operationCounts[operation] ?? 0
            let opsPerSec = duration > 0 ? Double(operations) / duration : 0
            
            report += "🔹 \(operation):
"
            report += "   Duration: \(String(format: "%.2f", duration))s
"
            report += "   Memory: \(String(format: "%.2f", Double(memory) / (1024 * 1024)))MB
"
            report += "   Operations: \(operations)
"
            report += "   Ops/sec: \(String(format: "%.2f", opsPerSec))

"
        }
        
        return report
    }
}
