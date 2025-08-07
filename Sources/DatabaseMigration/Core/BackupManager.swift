import Foundation
import CoreData

/// Manages database backups before and after migrations
public class BackupManager {
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let backupDirectory: URL
    private let maxBackupCount: Int
    
    // MARK: - Initialization
    
    public init(backupDirectory: URL? = nil, maxBackupCount: Int = 10) {
        self.maxBackupCount = maxBackupCount
        
        if let customDirectory = backupDirectory {
            self.backupDirectory = customDirectory
        } else {
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.backupDirectory = documentsPath.appendingPathComponent("DatabaseBackups")
        }
        
        createBackupDirectoryIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// Create a backup of the database before migration
    /// - Parameters:
    ///   - databaseURL: URL of the database to backup
    ///   - migrationVersion: Version number for the migration
    /// - Returns: URL of the created backup
    @discardableResult
    public func createBackup(databaseURL: URL, migrationVersion: Int) throws -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let backupName = "backup_v\(migrationVersion)_\(timestamp).db"
        let backupURL = backupDirectory.appendingPathComponent(backupName)
        
        // Create backup
        try fileManager.copyItem(at: databaseURL, to: backupURL)
        
        // Create metadata file
        let metadata = BackupMetadata(
            originalURL: databaseURL,
            backupURL: backupURL,
            migrationVersion: migrationVersion,
            timestamp: Date(),
            fileSize: try fileManager.attributesOfItem(atPath: backupURL.path)[.size] as? Int64 ?? 0
        )
        
        try saveMetadata(metadata, for: backupURL)
        
        // Clean old backups
        try cleanOldBackups()
        
        return backupURL
    }
    
    /// Restore database from backup
    /// - Parameters:
    ///   - backupURL: URL of the backup to restore from
    ///   - targetURL: URL where to restore the database
    public func restoreBackup(from backupURL: URL, to targetURL: URL) throws {
        // Verify backup exists
        guard fileManager.fileExists(atPath: backupURL.path) else {
            throw BackupError.backupNotFound
        }
        
        // Remove existing database if it exists
        if fileManager.fileExists(atPath: targetURL.path) {
            try fileManager.removeItem(at: targetURL)
        }
        
        // Restore backup
        try fileManager.copyItem(at: backupURL, to: targetURL)
    }
    
    /// List all available backups
    /// - Returns: Array of backup metadata
    public func listBackups() throws -> [BackupMetadata] {
        let backupFiles = try fileManager.contentsOfDirectory(
            at: backupDirectory,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ).filter { $0.pathExtension == "db" }
        
        return try backupFiles.compactMap { backupURL in
            let metadataURL = backupURL.appendingPathExtension("metadata")
            guard fileManager.fileExists(atPath: metadataURL.path) else { return nil }
            
            let data = try Data(contentsOf: metadataURL)
            return try JSONDecoder().decode(BackupMetadata.self, from: data)
        }.sorted { $0.timestamp > $1.timestamp }
    }
    
    /// Delete a specific backup
    /// - Parameter backupURL: URL of the backup to delete
    public func deleteBackup(at backupURL: URL) throws {
        guard fileManager.fileExists(atPath: backupURL.path) else {
            throw BackupError.backupNotFound
        }
        
        // Delete backup file
        try fileManager.removeItem(at: backupURL)
        
        // Delete metadata file
        let metadataURL = backupURL.appendingPathExtension("metadata")
        if fileManager.fileExists(atPath: metadataURL.path) {
            try fileManager.removeItem(at: metadataURL)
        }
    }
    
    /// Get backup statistics
    /// - Returns: Backup statistics
    public func getBackupStatistics() throws -> BackupStatistics {
        let backups = try listBackups()
        
        let totalSize = backups.reduce(0) { $0 + $1.fileSize }
        let averageSize = backups.isEmpty ? 0 : totalSize / Int64(backups.count)
        let oldestBackup = backups.last?.timestamp
        let newestBackup = backups.first?.timestamp
        
        return BackupStatistics(
            totalBackups: backups.count,
            totalSize: totalSize,
            averageSize: averageSize,
            oldestBackup: oldestBackup,
            newestBackup: newestBackup
        )
    }
    
    // MARK: - Private Methods
    
    private func createBackupDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: backupDirectory.path) {
            try? fileManager.createDirectory(
                at: backupDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
    private func saveMetadata(_ metadata: BackupMetadata, for backupURL: URL) throws {
        let metadataURL = backupURL.appendingPathExtension("metadata")
        let data = try JSONEncoder().encode(metadata)
        try data.write(to: metadataURL)
    }
    
    private func cleanOldBackups() throws {
        let backups = try listBackups()
        
        if backups.count > maxBackupCount {
            let backupsToDelete = backups[maxBackupCount...]
            for backup in backupsToDelete {
                try deleteBackup(at: backup.backupURL)
            }
        }
    }
}

// MARK: - Supporting Types

public struct BackupMetadata: Codable {
    public let originalURL: URL
    public let backupURL: URL
    public let migrationVersion: Int
    public let timestamp: Date
    public let fileSize: Int64
    
    public var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

public struct BackupStatistics {
    public let totalBackups: Int
    public let totalSize: Int64
    public let averageSize: Int64
    public let oldestBackup: Date?
    public let newestBackup: Date?
    
    public var formattedTotalSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
    
    public var formattedAverageSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: averageSize)
    }
}

public enum BackupError: Error, LocalizedError {
    case backupNotFound
    case backupCreationFailed
    case backupRestoreFailed
    case metadataCorrupted
    
    public var errorDescription: String? {
        switch self {
        case .backupNotFound:
            return "Backup file not found"
        case .backupCreationFailed:
            return "Failed to create backup"
        case .backupRestoreFailed:
            return "Failed to restore backup"
        case .metadataCorrupted:
            return "Backup metadata is corrupted"
        }
    }
}
