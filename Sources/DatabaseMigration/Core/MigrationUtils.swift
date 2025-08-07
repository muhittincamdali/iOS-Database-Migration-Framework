import Foundation
import CoreData

/// Utility functions for database migrations
public class MigrationUtils {
    
    // MARK: - Constants
    
    public static let defaultBatchSize = 1000
    public static let defaultTimeout: TimeInterval = 300 // 5 minutes
    
    // MARK: - Public Methods
    
    /// Generate a unique migration ID
    /// - Returns: Unique migration identifier
    public static func generateMigrationID() -> String {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let randomString = String((0..<8).map { _ in "abcdefghijklmnopqrstuvwxyz0123456789".randomElement()! })
        return "migration_\(timestamp)_\(randomString)"
    }
    
    /// Calculate the size of a database file
    /// - Parameter databaseURL: URL of the database file
    /// - Returns: Size in bytes, or nil if file does not exist
    public static func getDatabaseSize(at databaseURL: URL) -> Int64? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: databaseURL.path) else {
            return nil
        }
        return attributes[.size] as? Int64
    }
    
    /// Format file size for display
    /// - Parameter bytes: Size in bytes
    /// - Returns: Formatted size string
    public static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    /// Calculate optimal batch size based on available memory
    /// - Returns: Recommended batch size
    public static func calculateOptimalBatchSize() -> Int {
        let memoryInfo = getMemoryInfo()
        let availableMemory = memoryInfo.availableMemory
        
        // Use 10% of available memory for batch operations
        let memoryForBatch = availableMemory * 0.1
        let estimatedRecordSize: Int64 = 1024 // 1KB per record estimate
        let optimalBatchSize = Int(memoryForBatch / estimatedRecordSize)
        
        return max(100, min(optimalBatchSize, 10000)) // Between 100 and 10000
    }
    
    /// Get system memory information
    /// - Returns: Memory information
    public static func getMemoryInfo() -> MemoryInfo {
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
            return MemoryInfo(
                totalMemory: Int64(info.virtual_size),
                usedMemory: Int64(info.resident_size),
                availableMemory: Int64(info.virtual_size - info.resident_size)
            )
        } else {
            return MemoryInfo(totalMemory: 0, usedMemory: 0, availableMemory: 0)
        }
    }
    
    /// Validate database file integrity
    /// - Parameter databaseURL: URL of the database to validate
    /// - Returns: Validation result
    public static func validateDatabaseIntegrity(at databaseURL: URL) -> DatabaseIntegrityResult {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            return DatabaseIntegrityResult(isValid: false, errors: ["Database file does not exist"])
        }
        
        var errors: [String] = []
        
        // Check file size
        if let size = getDatabaseSize(at: databaseURL), size == 0 {
            errors.append("Database file is empty")
        }
        
        // Check file permissions
        if !FileManager.default.isReadableFile(atPath: databaseURL.path) {
            errors.append("Database file is not readable")
        }
        
        // Check if file is corrupted (basic check)
        if let data = try? Data(contentsOf: databaseURL), data.count < 100 {
            errors.append("Database file appears to be corrupted (too small)")
        }
        
        return DatabaseIntegrityResult(
            isValid: errors.isEmpty,
            errors: errors
        )
    }
    
    /// Create a temporary database for testing
    /// - Parameter name: Name for the temporary database
    /// - Returns: URL of the temporary database
    public static func createTemporaryDatabase(named name: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempDBURL = tempDir.appendingPathComponent("\(name)_\(UUID().uuidString).db")
        return tempDBURL
    }
    
    /// Clean up temporary databases
    /// - Parameter olderThan: Remove databases older than this date
    public static func cleanupTemporaryDatabases(olderThan date: Date = Date().addingTimeInterval(-3600)) {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(
                at: tempDir,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            ).filter { $0.pathExtension == "db" && $0.lastPathComponent.contains("temp") }
            
            for fileURL in tempFiles {
                if let creationDate = try? fileURL.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   creationDate < date {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("Failed to cleanup temporary databases: \(error)")
        }
    }
    
    /// Calculate migration progress percentage
    /// - Parameters:
    ///   - current: Current progress value
    ///   - total: Total value
    /// - Returns: Progress percentage (0-100)
    public static func calculateProgress(current: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(100.0, Double(current) / Double(total) * 100.0)
    }
    
    /// Format duration for display
    /// - Parameter duration: Duration in seconds
    /// - Returns: Formatted duration string
    public static func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 60 {
            return String(format: "%.1fs", duration)
        } else if duration < 3600 {
            let minutes = Int(duration / 60)
            let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
            return "\(minutes)m \(seconds)s"
        } else {
            let hours = Int(duration / 3600)
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)h \(minutes)m"
        }
    }
    
    /// Generate a checksum for data integrity verification
    /// - Parameter data: Data to checksum
    /// - Returns: SHA256 checksum
    public static func generateChecksum(for data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Verify data integrity using checksum
    /// - Parameters:
    ///   - data: Data to verify
    ///   - expectedChecksum: Expected checksum
    /// - Returns: True if checksums match
    public static func verifyChecksum(data: Data, expectedChecksum: String) -> Bool {
        let actualChecksum = generateChecksum(for: data)
        return actualChecksum == expectedChecksum
    }
}

// MARK: - Supporting Types

public struct MemoryInfo {
    public let totalMemory: Int64
    public let usedMemory: Int64
    public let availableMemory: Int64
    
    public var formattedTotalMemory: String {
        return MigrationUtils.formatFileSize(totalMemory)
    }
    
    public var formattedUsedMemory: String {
        return MigrationUtils.formatFileSize(usedMemory)
    }
    
    public var formattedAvailableMemory: String {
        return MigrationUtils.formatFileSize(availableMemory)
    }
    
    public var memoryUsagePercentage: Double {
        guard totalMemory > 0 else { return 0 }
        return Double(usedMemory) / Double(totalMemory) * 100.0
    }
}

public struct DatabaseIntegrityResult {
    public let isValid: Bool
    public let errors: [String]
    
    public var formattedReport: String {
        if isValid {
            return "✅ Database integrity check passed"
        } else {
            var report = "❌ Database integrity check failed:
"
            for error in errors {
                report += "  • \(error)
"
            }
            return report
        }
    }
}

// MARK: - CommonCrypto Import

import CommonCrypto
