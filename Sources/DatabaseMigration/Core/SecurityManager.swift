import Foundation
import Security
import CryptoKit

/// Manages security aspects of database migrations
public class SecurityManager {
    
    // MARK: - Properties
    
    private let keychain = KeychainWrapper.standard
    private var encryptionKey: SymmetricKey?
    private let keychainService = "com.database.migration.framework"
    
    // MARK: - Initialization
    
    public init() {
        setupEncryptionKey()
    }
    
    // MARK: - Public Methods
    
    /// Encrypt sensitive data
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data
    public func encryptData(_ data: Data) throws -> Data {
        guard let key = encryptionKey else {
            throw SecurityError.encryptionKeyNotAvailable
        }
        
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined ?? Data()
    }
    
    /// Decrypt sensitive data
    /// - Parameter encryptedData: Data to decrypt
    /// - Returns: Decrypted data
    public func decryptData(_ encryptedData: Data) throws -> Data {
        guard let key = encryptionKey else {
            throw SecurityError.encryptionKeyNotAvailable
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    /// Encrypt database file
    /// - Parameter databaseURL: URL of the database to encrypt
    /// - Returns: URL of the encrypted database
    public func encryptDatabase(at databaseURL: URL) throws -> URL {
        let data = try Data(contentsOf: databaseURL)
        let encryptedData = try encryptData(data)
        
        let encryptedURL = databaseURL.appendingPathExtension("encrypted")
        try encryptedData.write(to: encryptedURL)
        
        return encryptedURL
    }
    
    /// Decrypt database file
    /// - Parameter encryptedDatabaseURL: URL of the encrypted database
    /// - Returns: URL of the decrypted database
    public func decryptDatabase(at encryptedDatabaseURL: URL) throws -> URL {
        let encryptedData = try Data(contentsOf: encryptedDatabaseURL)
        let decryptedData = try decryptData(encryptedData)
        
        let decryptedURL = encryptedDatabaseURL.deletingPathExtension()
        try decryptedData.write(to: decryptedURL)
        
        return decryptedURL
    }
    
    /// Store sensitive information in keychain
    /// - Parameters:
    ///   - value: Value to store
    ///   - key: Key for the value
    public func storeInKeychain(_ value: String, forKey key: String) throws {
        let success = keychain.set(value, forKey: key, withAccessibility: .afterFirstUnlock)
        
        if !success {
            throw SecurityError.keychainStorageFailed
        }
    }
    
    /// Retrieve sensitive information from keychain
    /// - Parameter key: Key for the value
    /// - Returns: Stored value
    public func retrieveFromKeychain(forKey key: String) throws -> String {
        guard let value = keychain.string(forKey: key) else {
            throw SecurityError.keychainRetrievalFailed
        }
        
        return value
    }
    
    /// Remove sensitive information from keychain
    /// - Parameter key: Key to remove
    public func removeFromKeychain(forKey key: String) {
        keychain.removeObject(forKey: key)
    }
    
    /// Generate a secure random string
    /// - Parameter length: Length of the string
    /// - Returns: Secure random string
    public func generateSecureRandomString(length: Int = 32) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    /// Generate a secure random data
    /// - Parameter length: Length of the data
    /// - Returns: Secure random data
    public func generateSecureRandomData(length: Int = 32) -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        return Data(bytes)
    }
    
    /// Hash data using SHA256
    /// - Parameter data: Data to hash
    /// - Returns: SHA256 hash
    public func hashData(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verify data integrity using hash
    /// - Parameters:
    ///   - data: Data to verify
    ///   - expectedHash: Expected hash
    /// - Returns: True if hashes match
    public func verifyDataIntegrity(data: Data, expectedHash: String) -> Bool {
        let actualHash = hashData(data)
        return actualHash == expectedHash
    }
    
    /// Create a secure backup of sensitive data
    /// - Parameter data: Data to backup
    /// - Returns: Encrypted backup data
    public func createSecureBackup(_ data: Data) throws -> SecureBackup {
        let encryptedData = try encryptData(data)
        let checksum = hashData(data)
        let timestamp = Date()
        
        return SecureBackup(
            encryptedData: encryptedData,
            checksum: checksum,
            timestamp: timestamp,
            version: "1.0"
        )
    }
    
    /// Restore data from secure backup
    /// - Parameter backup: Secure backup to restore from
    /// - Returns: Restored data
    public func restoreFromSecureBackup(_ backup: SecureBackup) throws -> Data {
        let decryptedData = try decryptData(backup.encryptedData)
        
        // Verify integrity
        let actualChecksum = hashData(decryptedData)
        guard actualChecksum == backup.checksum else {
            throw SecurityError.backupIntegrityCheckFailed
        }
        
        return decryptedData
    }
    
    /// Get security audit log
    /// - Returns: Security audit entries
    public func getSecurityAuditLog() -> [SecurityAuditEntry] {
        // Implementation would typically read from a secure log file
        return []
    }
    
    /// Clear security audit log
    public func clearSecurityAuditLog() {
        // Implementation would typically clear the secure log file
    }
    
    // MARK: - Private Methods
    
    private func setupEncryptionKey() {
        // Try to retrieve existing key from keychain
        if let existingKeyData = keychain.data(forKey: "encryption_key") {
            encryptionKey = SymmetricKey(data: existingKeyData)
        } else {
            // Generate new key
            let newKey = SymmetricKey(size: .bits256)
            keychain.set(newKey.withUnsafeBytes { Data($0) }, forKey: "encryption_key")
            encryptionKey = newKey
        }
    }
}

// MARK: - Supporting Types

public struct SecureBackup: Codable {
    public let encryptedData: Data
    public let checksum: String
    public let timestamp: Date
    public let version: String
    
    public var formattedTimestamp: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: timestamp)
    }
}

public struct SecurityAuditEntry: Codable {
    public let id: UUID
    public let timestamp: Date
    public let action: String
    public let details: String
    public let severity: SecuritySeverity
    
    public init(action: String, details: String, severity: SecuritySeverity = .info) {
        self.id = UUID()
        self.timestamp = Date()
        self.action = action
        self.details = details
        self.severity = severity
    }
}

public enum SecuritySeverity: String, Codable, CaseIterable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
    public var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
}

public enum SecurityError: Error, LocalizedError {
    case encryptionKeyNotAvailable
    case encryptionFailed
    case decryptionFailed
    case keychainStorageFailed
    case keychainRetrievalFailed
    case backupIntegrityCheckFailed
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .encryptionKeyNotAvailable:
            return "Encryption key is not available"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .keychainStorageFailed:
            return "Failed to store data in keychain"
        case .keychainRetrievalFailed:
            return "Failed to retrieve data from keychain"
        case .backupIntegrityCheckFailed:
            return "Backup integrity check failed"
        case .invalidData:
            return "Invalid data provided"
        }
    }
}

// MARK: - KeychainWrapper (Simplified implementation)

public class KeychainWrapper {
    public static let standard = KeychainWrapper()
    
    private init() {}
    
    public func set(_ value: String, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility) -> Bool {
        let data = value.data(using: .utf8)!
        return set(data, forKey: key, withAccessibility: accessibility)
    }
    
    public func set(_ value: Data, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: accessibility.rawValue
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func string(forKey key: String) -> String? {
        guard let data = data(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func data(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return (result as? Data)
    }
    
    public func removeObject(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

public enum KeychainItemAccessibility: String {
    case afterFirstUnlock = kSecAttrAccessibleAfterFirstUnlock as String
    case whenUnlocked = kSecAttrAccessibleWhenUnlocked as String
    case always = kSecAttrAccessibleAlways as String
}
