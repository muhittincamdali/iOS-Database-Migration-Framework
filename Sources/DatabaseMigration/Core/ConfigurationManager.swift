import Foundation
import Combine

/// Advanced configuration management system for database migrations
@available(iOS 15.0, *)
public final class ConfigurationManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentConfiguration: MigrationConfiguration
    @Published public var isConfigurationValid: Bool = false
    @Published public var configurationErrors: [ConfigurationError] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let validationQueue = DispatchQueue(label: "com.migration.config.validation", qos: .userInitiated)
    private let configurationStorage: ConfigurationStorageProtocol
    
    // MARK: - Initialization
    public init(storage: ConfigurationStorageProtocol = UserDefaultsConfigurationStorage()) {
        self.configurationStorage = storage
        self.currentConfiguration = MigrationConfiguration.default
        setupBindings()
        validateConfiguration()
    }
    
    // MARK: - Public Methods
    
    /// Configure migration with custom settings
    /// - Parameter configuration: The migration configuration to apply
    public func configure(with configuration: MigrationConfiguration) {
        currentConfiguration = configuration
        validateConfiguration()
        saveConfiguration()
    }
    
    /// Load configuration from persistent storage
    public func loadConfiguration() {
        guard let savedConfig = configurationStorage.loadConfiguration() else {
            print("No saved configuration found, using defaults")
            return
        }
        
        currentConfiguration = savedConfig
        validateConfiguration()
    }
    
    /// Save current configuration to persistent storage
    public func saveConfiguration() {
        configurationStorage.saveConfiguration(currentConfiguration)
    }
    
    /// Reset configuration to default values
    public func resetToDefaults() {
        currentConfiguration = MigrationConfiguration.default
        validateConfiguration()
        saveConfiguration()
    }
    
    /// Validate current configuration and return detailed results
    /// - Returns: Configuration validation result
    public func validateConfiguration() -> ConfigurationValidationResult {
        var errors: [ConfigurationError] = []
        var warnings: [ConfigurationWarning] = []
        
        // Validate version compatibility
        if !isVersionCompatible(currentConfiguration.targetVersion) {
            errors.append(.incompatibleVersion(currentConfiguration.targetVersion))
        }
        
        // Validate migration path
        if !isMigrationPathValid() {
            errors.append(.invalidMigrationPath)
        }
        
        // Validate performance settings
        if currentConfiguration.batchSize > 10000 {
            warnings.append(.largeBatchSize(currentConfiguration.batchSize))
        }
        
        // Validate security settings
        if currentConfiguration.enableEncryption && !currentConfiguration.encryptionKey.isEmpty {
            errors.append(.missingEncryptionKey)
        }
        
        // Validate analytics settings
        if currentConfiguration.enableAnalytics && !currentConfiguration.analyticsEndpoint.isEmpty {
            warnings.append(.analyticsEndpointNotConfigured)
        }
        
        let isValid = errors.isEmpty
        isConfigurationValid = isValid
        configurationErrors = errors
        
        return ConfigurationValidationResult(
            isValid: isValid,
            errors: errors,
            warnings: warnings
        )
    }
    
    /// Update specific configuration parameters
    /// - Parameters:
    ///   - keyPath: The configuration key path to update
    ///   - value: The new value
    public func updateConfiguration<T>(_ keyPath: WritableKeyPath<MigrationConfiguration, T>, value: T) {
        currentConfiguration[keyPath: keyPath] = value
        validateConfiguration()
        saveConfiguration()
    }
    
    /// Export current configuration to JSON
    /// - Returns: JSON string representation of configuration
    public func exportConfiguration() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(currentConfiguration)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to export configuration: \(error)")
            return nil
        }
    }
    
    /// Import configuration from JSON
    /// - Parameter jsonString: JSON string containing configuration
    /// - Returns: Success status of import operation
    public func importConfiguration(from jsonString: String) -> Bool {
        let decoder = JSONDecoder()
        
        do {
            guard let data = jsonString.data(using: .utf8) else {
                return false
            }
            
            let configuration = try decoder.decode(MigrationConfiguration.self, from: data)
            currentConfiguration = configuration
            validateConfiguration()
            saveConfiguration()
            return true
        } catch {
            print("Failed to import configuration: \(error)")
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        $currentConfiguration
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.validateConfiguration()
            }
            .store(in: &cancellables)
    }
    
    private func isVersionCompatible(_ version: String) -> Bool {
        // Version compatibility logic
        let components = version.split(separator: ".").compactMap { Int($0) }
        guard components.count >= 2 else { return false }
        
        let major = components[0]
        let minor = components[1]
        
        // Basic version compatibility check
        return major >= 1 && minor >= 0
    }
    
    private func isMigrationPathValid() -> Bool {
        // Migration path validation logic
        let currentVersion = currentConfiguration.currentVersion
        let targetVersion = currentConfiguration.targetVersion
        
        // Ensure target version is newer than current
        return targetVersion > currentVersion
    }
}

// MARK: - Supporting Types

/// Configuration validation result
public struct ConfigurationValidationResult {
    public let isValid: Bool
    public let errors: [ConfigurationError]
    public let warnings: [ConfigurationWarning]
}

/// Configuration errors
public enum ConfigurationError: LocalizedError {
    case incompatibleVersion(String)
    case invalidMigrationPath
    case missingEncryptionKey
    case invalidConfiguration
    
    public var errorDescription: String? {
        switch self {
        case .incompatibleVersion(let version):
            return "Incompatible version: \(version)"
        case .invalidMigrationPath:
            return "Invalid migration path"
        case .missingEncryptionKey:
            return "Encryption enabled but no key provided"
        case .invalidConfiguration:
            return "Invalid configuration"
        }
    }
}

/// Configuration warnings
public enum ConfigurationWarning: LocalizedError {
    case largeBatchSize(Int)
    case analyticsEndpointNotConfigured
    
    public var errorDescription: String? {
        switch self {
        case .largeBatchSize(let size):
            return "Large batch size may impact performance: \(size)"
        case .analyticsEndpointNotConfigured:
            return "Analytics enabled but endpoint not configured"
        }
    }
}

/// Configuration storage protocol
public protocol ConfigurationStorageProtocol {
    func saveConfiguration(_ configuration: MigrationConfiguration)
    func loadConfiguration() -> MigrationConfiguration?
}

/// UserDefaults-based configuration storage
public class UserDefaultsConfigurationStorage: ConfigurationStorageProtocol {
    private let key = "MigrationConfiguration"
    
    public func saveConfiguration(_ configuration: MigrationConfiguration) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(configuration) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    public func loadConfiguration() -> MigrationConfiguration? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(MigrationConfiguration.self, from: data)
    }
}
