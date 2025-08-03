import Foundation
import Combine

/// Comprehensive error handling system for database migrations
@available(iOS 15.0, *)
public final class ErrorHandler: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var currentErrors: [MigrationError] = []
    @Published public var errorCount: Int = 0
    @Published public var lastError: MigrationError?
    
    // MARK: - Private Properties
    private var errorQueue = DispatchQueue(label: "com.migration.error", qos: .utility)
    private var errorStorage: ErrorStorageProtocol
    private var errorAnalytics: ErrorAnalyticsProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(storage: ErrorStorageProtocol = UserDefaultsErrorStorage(), analytics: ErrorAnalyticsProtocol? = nil) {
        self.errorStorage = storage
        self.errorAnalytics = analytics
        setupErrorHandling()
    }
    
    // MARK: - Public Methods
    
    /// Handle migration error with detailed context
    /// - Parameters:
    ///   - error: The migration error to handle
    ///   - context: Additional context information
    ///   - severity: Error severity level
    public func handleError(_ error: MigrationError, context: ErrorContext? = nil, severity: ErrorSeverity = .error) {
        errorQueue.async { [weak self] in
            self?.processError(error, context: context, severity: severity)
        }
    }
    
    /// Handle system error and convert to migration error
    /// - Parameters:
    ///   - error: System error to handle
    ///   - context: Additional context information
    public func handleSystemError(_ error: Error, context: ErrorContext? = nil) {
        let migrationError = MigrationError.systemError(error.localizedDescription)
        handleError(migrationError, context: context, severity: .error)
    }
    
    /// Clear all current errors
    public func clearErrors() {
        DispatchQueue.main.async { [weak self] in
            self?.currentErrors.removeAll()
            self?.errorCount = 0
            self?.lastError = nil
        }
    }
    
    /// Get errors filtered by severity
    /// - Parameter severity: Minimum severity level to include
    /// - Returns: Filtered array of errors
    public func getErrors(withSeverity severity: ErrorSeverity) -> [MigrationError] {
        return currentErrors.filter { $0.severity.rawValue >= severity.rawValue }
    }
    
    /// Get errors for specific migration step
    /// - Parameter step: Migration step identifier
    /// - Returns: Array of errors for the specified step
    public func getErrors(forStep step: String) -> [MigrationError] {
        return currentErrors.filter { $0.context?.step == step }
    }
    
    /// Export error log to JSON
    /// - Returns: JSON string containing error log
    public func exportErrorLog() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let errorLog = ErrorLog(
                errors: currentErrors,
                timestamp: Date(),
                totalCount: errorCount
            )
            let data = try encoder.encode(errorLog)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to export error log: \(error)")
            return nil
        }
    }
    
    /// Import error log from JSON
    /// - Parameter jsonString: JSON string containing error log
    /// - Returns: Success status of import operation
    public func importErrorLog(from jsonString: String) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            guard let data = jsonString.data(using: .utf8) else {
                return false
            }
            
            let errorLog = try decoder.decode(ErrorLog.self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.currentErrors = errorLog.errors
                self?.errorCount = errorLog.totalCount
            }
            return true
        } catch {
            print("Failed to import error log: \(error)")
            return false
        }
    }
    
    /// Retry failed operations
    /// - Parameter operation: Operation to retry
    /// - Returns: Success status of retry operation
    public func retryOperation(_ operation: @escaping () async throws -> Void) async -> Bool {
        do {
            try await operation()
            return true
        } catch {
            let migrationError = MigrationError.retryFailed(error.localizedDescription)
            handleError(migrationError, severity: .warning)
            return false
        }
    }
    
    /// Set error analytics provider
    /// - Parameter analytics: Analytics provider to use
    public func setErrorAnalytics(_ analytics: ErrorAnalyticsProtocol) {
        self.errorAnalytics = analytics
    }
    
    // MARK: - Private Methods
    
    private func setupErrorHandling() {
        $currentErrors
            .sink { [weak self] errors in
                self?.errorCount = errors.count
                self?.lastError = errors.last
                self?.saveErrorsToStorage()
            }
            .store(in: &cancellables)
    }
    
    private func processError(_ error: MigrationError, context: ErrorContext?, severity: ErrorSeverity) {
        var processedError = error
        processedError.context = context
        processedError.severity = severity
        processedError.timestamp = Date()
        
        DispatchQueue.main.async { [weak self] in
            self?.currentErrors.append(processedError)
        }
        
        // Log error to analytics
        errorAnalytics?.logError(processedError)
        
        // Save error to persistent storage
        errorStorage.saveError(processedError)
        
        // Handle critical errors
        if severity == .critical {
            handleCriticalError(processedError)
        }
    }
    
    private func handleCriticalError(_ error: MigrationError) {
        // Implement critical error handling logic
        print("Critical error detected: \(error.localizedDescription)")
        
        // Send notification to user
        NotificationCenter.default.post(
            name: .migrationCriticalError,
            object: error
        )
    }
    
    private func saveErrorsToStorage() {
        errorStorage.saveErrors(currentErrors)
    }
}

// MARK: - Supporting Types

/// Migration error types
public enum MigrationError: LocalizedError, Codable {
    case validationFailed(String)
    case schemaMismatch(String)
    case dataCorruption(String)
    case insufficientPermissions(String)
    case networkError(String)
    case timeoutError(String)
    case systemError(String)
    case retryFailed(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .schemaMismatch(let message):
            return "Schema mismatch: \(message)"
        case .dataCorruption(let message):
            return "Data corruption: \(message)"
        case .insufficientPermissions(let message):
            return "Insufficient permissions: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .timeoutError(let message):
            return "Timeout error: \(message)"
        case .systemError(let message):
            return "System error: \(message)"
        case .retryFailed(let message):
            return "Retry failed: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
    
    // MARK: - Codable Implementation
    
    public var context: ErrorContext?
    public var severity: ErrorSeverity = .error
    public var timestamp: Date = Date()
    
    private enum CodingKeys: String, CodingKey {
        case type, message, context, severity, timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let message = try container.decode(String.self, forKey: .message)
        
        switch type {
        case "validationFailed":
            self = .validationFailed(message)
        case "schemaMismatch":
            self = .schemaMismatch(message)
        case "dataCorruption":
            self = .dataCorruption(message)
        case "insufficientPermissions":
            self = .insufficientPermissions(message)
        case "networkError":
            self = .networkError(message)
        case "timeoutError":
            self = .timeoutError(message)
        case "systemError":
            self = .systemError(message)
        case "retryFailed":
            self = .retryFailed(message)
        case "unknownError":
            self = .unknownError(message)
        default:
            self = .unknownError(message)
        }
        
        context = try container.decodeIfPresent(ErrorContext.self, forKey: .context)
        severity = try container.decode(ErrorSeverity.self, forKey: .severity)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let type: String
        switch self {
        case .validationFailed: type = "validationFailed"
        case .schemaMismatch: type = "schemaMismatch"
        case .dataCorruption: type = "dataCorruption"
        case .insufficientPermissions: type = "insufficientPermissions"
        case .networkError: type = "networkError"
        case .timeoutError: type = "timeoutError"
        case .systemError: type = "systemError"
        case .retryFailed: type = "retryFailed"
        case .unknownError: type = "unknownError"
        }
        
        try container.encode(type, forKey: .type)
        try container.encode(localizedDescription, forKey: .message)
        try container.encodeIfPresent(context, forKey: .context)
        try container.encode(severity, forKey: .severity)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

/// Error severity levels
public enum ErrorSeverity: Int, Codable, CaseIterable {
    case info = 0
    case warning = 1
    case error = 2
    case critical = 3
}

/// Error context information
public struct ErrorContext: Codable {
    public let step: String?
    public let entity: String?
    public let operation: String?
    public let additionalInfo: [String: String]?
    
    public init(step: String? = nil, entity: String? = nil, operation: String? = nil, additionalInfo: [String: String]? = nil) {
        self.step = step
        self.entity = entity
        self.operation = operation
        self.additionalInfo = additionalInfo
    }
}

/// Error log structure
public struct ErrorLog: Codable {
    public let errors: [MigrationError]
    public let timestamp: Date
    public let totalCount: Int
}

/// Error storage protocol
public protocol ErrorStorageProtocol {
    func saveError(_ error: MigrationError)
    func saveErrors(_ errors: [MigrationError])
    func loadErrors() -> [MigrationError]
    func clearErrors()
}

/// Error analytics protocol
public protocol ErrorAnalyticsProtocol {
    func logError(_ error: MigrationError)
    func getErrorStatistics() -> ErrorStatistics
}

/// Error statistics
public struct ErrorStatistics {
    public let totalErrors: Int
    public let errorsBySeverity: [ErrorSeverity: Int]
    public let errorsByType: [String: Int]
    public let averageResolutionTime: TimeInterval
}

/// UserDefaults-based error storage
public class UserDefaultsErrorStorage: ErrorStorageProtocol {
    private let key = "MigrationErrors"
    
    public func saveError(_ error: MigrationError) {
        var errors = loadErrors()
        errors.append(error)
        saveErrors(errors)
    }
    
    public func saveErrors(_ errors: [MigrationError]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(errors) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    public func loadErrors() -> [MigrationError] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([MigrationError].self, from: data)) ?? []
    }
    
    public func clearErrors() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let migrationCriticalError = Notification.Name("migrationCriticalError")
}
